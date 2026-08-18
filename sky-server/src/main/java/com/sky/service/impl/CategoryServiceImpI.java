package com.sky.service.impl;

import com.github.pagehelper.Page;
import com.github.pagehelper.PageHelper;
import com.sky.constant.MessageConstant;
import com.sky.constant.StatusConstant;
import com.sky.context.BaseContext;
import com.sky.dto.CategoryDTO;
import com.sky.dto.CategoryPageQueryDTO;
import com.sky.entity.Category;
import com.sky.exception.DeletionNotAllowedException;
import com.sky.mapper.CategoryMapper;
import com.sky.mapper.DishMapper;
import com.sky.mapper.SetmealMapper;
import com.sky.result.PageResult;
import com.sky.service.CategoryService;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 分类服务层实现类
 */
@Service
public class CategoryServiceImpI implements CategoryService {

	// 实例化mapper对象
	@Autowired
	private CategoryMapper categoryMapper;

	// 实例化mapper对象
	@Autowired
	private DishMapper dishMapper;

	// 实例化mapper对象
	@Autowired
	private SetmealMapper setmealMapper;

	/**
	 * 新增分类
	 *
	 * @param categoryDTO
	 */
	@Override
	public void save(CategoryDTO categoryDTO) {
		// 创建一个Category实体类对象
		Category category = new Category();
		// 对象属性拷贝
		BeanUtils.copyProperties(categoryDTO, category);
		// 分类状态默认为启用状态 1
		category.setStatus(StatusConstant.ENABLE);
		// 设置创建时间、修改时间
		category.setCreateTime(LocalDateTime.now());
		category.setUpdateTime(LocalDateTime.now());

		// 设置创建人、修改人（如果获取不到则默认用管理员id 1）
		Long userId = BaseContext.getCurrentId();
		if (userId == null) {
			userId = 1L;
		}
		category.setCreateUser(userId);
		category.setUpdateUser(userId);
		// 调用mapper层实现新增分类
		categoryMapper.insert(category);
	}

	/**
	 * 分类分页查询
	 *
	 * @param categoryPageQueryDTO
	 * @return
	 */
	@Override
	public PageResult pageQuery(CategoryPageQueryDTO categoryPageQueryDTO) {
		// 分页查询步骤，先把当前分页以及每页的记录数给插件PageHelper
		PageHelper.startPage(categoryPageQueryDTO.getPage(), categoryPageQueryDTO.getPageSize());
		// 调用mapper层实现分页查询
		Page<Category> page = categoryMapper.pageQuery(categoryPageQueryDTO);
		// getTotal总记录数，getResult返回的数据列表
		return new PageResult(page.getTotal(), page.getResult());
	}

	/**
	 * 根据id删除分类
	 *
	 * @param id
	 */
	@Override
	public void deleteById(Long id) {
		// 查询当前分类是否关联了菜品，如果关联了就抛出业务异常
		Integer count = dishMapper.countByCategoryId(id);
		if (count > 0) {
			// 当前分类下有菜品，不能删除
			throw new DeletionNotAllowedException(MessageConstant.CATEGORY_BE_RELATED_BY_DISH);
		}

		// 查询当前分类是否关联了套餐，如果关联了就抛出业务异常
		count = setmealMapper.countByCategoryId(id);
		if (count > 0) {
			// 当前分类下有套餐，不能删除
			throw new DeletionNotAllowedException(MessageConstant.CATEGORY_BE_RELATED_BY_SETMEAL);
		}

		// 调用mapper层实现删除分类数据
		categoryMapper.deleteById(id);
	}

	/**
	 * 修改分类
	 *
	 * @param categoryDTO
	 */
	@Override
	public void update(CategoryDTO categoryDTO) {
		// 创建一个Category实体类对象
		Category category = new Category();
		// 对象属性拷贝
		BeanUtils.copyProperties(categoryDTO, category);
		// 设置修改时间、修改人
		category.setUpdateTime(LocalDateTime.now());
		category.setUpdateUser(BaseContext.getCurrentId());

		// 调用mapper层实现修改分类
		categoryMapper.update(category);
	}

	/**
	 * 启用禁用分类
	 *
	 * @param status
	 * @param id
	 */
	@Override
	public void startOrStop(Integer status, Long id) {
		// 创建一个Category实体类对象
		Category category = Category.builder().id(id).status(status).updateTime(LocalDateTime.now())
				.updateUser(BaseContext.getCurrentId()).build();
		// 调用mapper层实现启用禁用分类
		categoryMapper.update(category);
	}

	/**
	 * 根据类型查询分类
	 *
	 * @param type
	 * @return
	 */
	@Override
	public List<Category> list(Integer type) {
		// 调用mapper层实现根据类型查询分类
		return categoryMapper.list(type);
	}

}
