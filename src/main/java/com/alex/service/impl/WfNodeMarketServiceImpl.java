package com.alex.service.impl;

import com.alex.mapper.WfNodeMarketMapper;
import com.alex.pojo.WfNodeMarket;
import com.alex.service.WfNodeMarketService;
import com.alex.utils.MyBatisUtil;
import org.apache.ibatis.session.SqlSession;
import java.util.List;

public class WfNodeMarketServiceImpl implements WfNodeMarketService {

    @Override
    public List<WfNodeMarket> getAllNodes() {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            return sqlSession.getMapper(WfNodeMarketMapper.class).getAllNodes();
        }
    }

    @Override
    public WfNodeMarket getNodeById(int id) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            return sqlSession.getMapper(WfNodeMarketMapper.class).getNodeById(id);
        }
    }

    @Override
    public boolean insertNode(WfNodeMarket node) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            int rows = sqlSession.getMapper(WfNodeMarketMapper.class).insertNode(node);
            sqlSession.commit(); // 🚨 发布节点属于写操作，必须 commit!
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteNodeById(int id) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            int rows = sqlSession.getMapper(WfNodeMarketMapper.class).deleteNodeById(id);
            sqlSession.commit();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<WfNodeMarket> getAllNodesForAdmin() {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            return sqlSession.getMapper(WfNodeMarketMapper.class).getAllNodesForAdmin();
        }
    }

    @Override
    public List<WfNodeMarket> getNodesByStatus(int status) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            return sqlSession.getMapper(WfNodeMarketMapper.class).getNodesByStatus(status);
        }
    }

    @Override
    public boolean updateNodeStatus(int id, int status) {
        try (SqlSession sqlSession = MyBatisUtil.getSqlSession()) {
            int rows = sqlSession.getMapper(WfNodeMarketMapper.class).updateNodeStatus(id, status);
            sqlSession.commit();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}