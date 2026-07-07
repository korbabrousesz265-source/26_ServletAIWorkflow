package com.alex.utils;

import com.google.gson.JsonObject;
import org.apache.poi.xslf.usermodel.*;

import java.io.OutputStream;
import java.util.List;
import java.util.Map;

public class PPTUtil {

    // ================= 经典稳定版：基于 TextRun 的无损样式替换 =================

    public static JsonObject extractSlideStructure(String pptPath) throws Exception {
        JsonObject structure = new JsonObject();
        try (java.io.FileInputStream fis = new java.io.FileInputStream(pptPath);
             XMLSlideShow ppt = new XMLSlideShow(fis)) {
            int slideNum = 1;
            for (XSLFSlide slide : ppt.getSlides()) {
                JsonObject texts = new JsonObject();
                java.util.Map<String, Integer> counts = new java.util.LinkedHashMap<>();

                for (XSLFShape shape : slide.getShapes()) {
                    extractTextsForStructure(shape, texts, counts);
                }
                if (texts.size() > 0) {
                    structure.add("slide_" + slideNum, texts);
                }
                slideNum++;
            }
        }
        return structure;
    }

    private static void extractTextsForStructure(XSLFShape shape, JsonObject texts, java.util.Map<String, Integer> counts) {
        if (shape instanceof XSLFGroupShape) {
            for (XSLFShape child : ((XSLFGroupShape) shape).getShapes()) extractTextsForStructure(child, texts, counts);
        } else if (shape instanceof XSLFTable) {
            for (XSLFTableRow row : ((XSLFTable) shape).getRows()) {
                for (XSLFTableCell cell : row.getCells()) extractTextsForStructure(cell, texts, counts);
            }
        } else if (shape instanceof XSLFTextShape) {
            String text = ((XSLFTextShape) shape).getText();
            if (text != null && !text.trim().isEmpty()) {
                String[] lines = text.split("[\r\n]+");
                for (String line : lines) {
                    String cleanLine = line.trim();
                    if (cleanLine.length() > 1) {
                        int c = counts.getOrDefault(cleanLine, 0) + 1;
                        counts.put(cleanLine, c);
                        // 使用下划线后缀，匹配大模型最喜欢的输出格式
                        texts.addProperty(cleanLine + "_" + c, "");
                    }
                }
            }
        }
    }

    public static void directFillPPT(String sourcePath, JsonObject aiJsonData, OutputStream out) throws Exception {
        try (java.io.FileInputStream fis = new java.io.FileInputStream(sourcePath);
             XMLSlideShow ppt = new XMLSlideShow(fis)) {

            int totalSlides = ppt.getSlides().size();
            System.out.println("📊 [PPTUtil] 模板共有 " + totalSlides + " 页幻灯片");
            System.out.println("📊 [PPTUtil] AI JSON 顶层 keys: " + aiJsonData.keySet());

            int slideNum = 1;
            for (XSLFSlide slide : ppt.getSlides()) {
                String expectedKey = "slide_" + slideNum;
                JsonObject slideMapping = null;

                for (String key : aiJsonData.keySet()) {
                    if (key.equalsIgnoreCase(expectedKey)) {
                        com.google.gson.JsonElement element = aiJsonData.get(key);
                        if (element.isJsonObject()) {
                            slideMapping = element.getAsJsonObject();
                            System.out.println("✅ [PPTUtil] 第 " + slideNum + " 页匹配成功! key=\"" + key + "\", 映射条目数=" + slideMapping.size());
                            System.out.println("   📝 映射内容: " + slideMapping.toString());
                        } else {
                            System.out.println("⚠️ [PPTUtil] 第 " + slideNum + " 页 key=\"" + key + "\" 的值不是 JsonObject!");
                        }
                        break;
                    }
                }

                if (slideMapping == null) {
                    System.out.println("❌ [PPTUtil] 第 " + slideNum + " 页未找到匹配的 key=\"" + expectedKey + "\"! 此页将保持模板原样。");
                    System.out.println("   🔍 当前 JSON 中可用的 keys: " + aiJsonData.keySet());
                }

                if (slideMapping != null) {
                    java.util.Set<String> usedKeys = new java.util.HashSet<>();
                    int shapeCount = 0;
                    for (XSLFShape shape : slide.getShapes()) {
                        shapeCount++;
                        fillShapeDirectly(shape, slideMapping, usedKeys);
                    }
                    System.out.println("   🔧 [PPTUtil] 第 " + slideNum + " 页共处理 " + shapeCount + " 个形状, 实际使用映射 " + usedKeys.size() + " 个");
                    if (usedKeys.size() > 0) {
                        System.out.println("   ✅ 已使用的 keys: " + usedKeys);
                    }
                    if (usedKeys.size() < slideMapping.size()) {
                        System.out.println("   ⚠️ 未使用的 keys: " +
                            slideMapping.keySet().stream()
                                .filter(k -> !usedKeys.contains(k))
                                .collect(java.util.stream.Collectors.toList()));
                    }
                }
                slideNum++;
            }
            ppt.write(out);
            System.out.println("✅ [PPTUtil] PPT 写入完成!");
        }
    }

    private static void fillShapeDirectly(XSLFShape shape, JsonObject slideMapping, java.util.Set<String> usedKeys) {
        if (shape instanceof XSLFGroupShape) {
            for (XSLFShape child : ((XSLFGroupShape) shape).getShapes()) fillShapeDirectly(child, slideMapping, usedKeys);
        } else if (shape instanceof XSLFTable) {
            for (XSLFTableRow row : ((XSLFTable) shape).getRows()) {
                for (XSLFTableCell cell : row.getCells()) fillShapeDirectly(cell, slideMapping, usedKeys);
            }
        } else if (shape instanceof XSLFTextShape) {
            XSLFTextShape textShape = (XSLFTextShape) shape;

            // 1. 获取最真实的物理文本
            String fullText = textShape.getText();
            String shapeName = shape.getShapeName();
            if (fullText == null || fullText.trim().isEmpty()) {
                System.out.println("   ⏭️ [形状] \"" + shapeName + "\" — 文本为空/仅空白，跳过");
                return;
            }

            System.out.println("   🔍 [形状] \"" + shapeName + "\" — 当前文本: \"" + fullText.trim().replace("\n","\\n") + "\"");

            boolean changed = false;
            for (Map.Entry<String, com.google.gson.JsonElement> entry : slideMapping.entrySet()) {
                String fullKey = entry.getKey().trim();
                if (usedKeys.contains(fullKey)) continue;

                String newValue = entry.getValue().getAsString();
                if (newValue == null || newValue.trim().isEmpty()) {
                    System.out.println("      ⏭️ key=\"" + fullKey + "\" 的新值为空，跳过");
                    continue;
                }

                // 2. 剥离大模型可能输出的 _1 或 _{1} 后缀
                String actualOldText = fullKey.replaceAll("_(?:\\{\\d+\\}|\\d+)$", "");

                System.out.println("      🔎 尝试匹配: fullKey=\"" + fullKey + "\" → 剥离后缀=\"" + actualOldText + "\"");

                if (!actualOldText.isEmpty() && fullText.contains(actualOldText)) {
                    // 👑 绝杀1：只替换第一处匹配，保留同名占位符给后续的 _2, _3
                    fullText = fullText.replaceFirst(
                            java.util.regex.Pattern.quote(actualOldText),
                            java.util.regex.Matcher.quoteReplacement(newValue)
                    );
                    changed = true;
                    usedKeys.add(fullKey);
                    System.out.println("      ✅ 替换成功! \"" + actualOldText + "\" → \"" + newValue + "\"");
                } else {
                    if (actualOldText.isEmpty()) {
                        System.out.println("      ❌ 剥离后缀后为空字符串，跳过");
                    } else {
                        System.out.println("      ❌ 文本中未找到 \"" + actualOldText + "\"，未匹配");
                    }
                }
            }

            if (changed) {
                // 净化回车换行，防止 XML 崩坏
                fullText = fullText.replaceAll("[\r\n]+", " ");
                // 👑 绝杀2：不管是不是幽灵占位符，直接调用 setText 强制实例化！彻底切断母版依赖！
                textShape.setText(fullText);
                System.out.println("   ✨ [形状] \"" + shapeName + "\" 已更新文本为: \"" + fullText + "\"");
            } else {
                System.out.println("   ⏭️ [形状] \"" + shapeName + "\" — 无匹配，保持原样");
            }
        }
    }

}