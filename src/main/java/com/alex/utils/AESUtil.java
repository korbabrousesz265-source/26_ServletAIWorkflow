package com.alex.utils;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class AESUtil {

    // 👑 全站主密钥 (Master Key) - 必须严格保持 16 位字符长度 (128 bit)
    // 实际商业项目中，这个密钥绝对不能写死在代码里，而是通过 System.getenv("MASTER_KEY") 从服务器环境变量读取
    private static final String MASTER_KEY = "WfEngine2026!@#$";
    private static final String ALGORITHM = "AES";

    /**
     * 加密：明文 -> 密文
     */
    public static String encrypt(String plainText) {
        if (plainText == null || plainText.trim().isEmpty()) return plainText;
        try {
            SecretKeySpec keySpec = new SecretKeySpec(MASTER_KEY.getBytes(StandardCharsets.UTF_8), ALGORITHM);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, keySpec);
            byte[] encryptedBytes = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(encryptedBytes);
        } catch (Exception e) {
            e.printStackTrace();
            return null; // 加密失败不落盘，保护原数据
        }
    }

    /**
     * 解密：密文 -> 明文
     */
    public static String decrypt(String cipherText) {
        if (cipherText == null || cipherText.trim().isEmpty()) return cipherText;
        try {
            SecretKeySpec keySpec = new SecretKeySpec(MASTER_KEY.getBytes(StandardCharsets.UTF_8), ALGORITHM);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, keySpec);
            byte[] decodedBytes = Base64.getDecoder().decode(cipherText);
            byte[] decryptedBytes = cipher.doFinal(decodedBytes);
            return new String(decryptedBytes, StandardCharsets.UTF_8);
        } catch (Exception e) {
            e.printStackTrace();
            return cipherText; // 如果解密失败（比如原数据本来就是明文未加密），直接返回原数据兜底
        }
    }
}