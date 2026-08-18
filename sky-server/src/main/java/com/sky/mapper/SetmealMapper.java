package com.sky.mapper;

import com.sky.dto.SetmealPageQueryDTO;
import com.sky.entity.Setmeal;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 套餐Mapper接口
 */
@Mapper
public interface SetmealMapper {

	/**
	 * 根据分类id查询套餐数量
	 *
	 * @param categoryId
	 * @return
	 */
	@Select("select count(id) from setmeal where category_id = #{categoryId}")
	Integer countByCategoryId(Long categoryId);

	/**
	 * 根据id查询套餐
	 *
	 * @param id
	 * @return
	 */
	@Select("select * from setmeal where id = #{id}")
	Setmeal getById(Long id);

	/**
	 * 根据分类id查询套餐
	 *
	 * @param categoryId
	 * @return
	 */
	@Select("select * from setmeal where category_id = #{categoryId}")
	List<Setmeal> getByCategoryId(Long categoryId);

	/**
	 * 插入套餐数据
	 *
	 * @param setmeal
	 */
	void insert(Setmeal setmeal);

	/**
	 * 套餐分页查询
	 *
	 * @param setmealPageQueryDTO
	 * @return
	 */
	List<Setmeal> pageQuery(SetmealPageQueryDTO setmealPageQueryDTO);

	/**
	 * 根据id删除套餐
	 *
	 * @param id
	 */
	void deleteById(Long id);

	/**
	 * 根据id动态修改套餐
	 *
	 * @param setmeal
	 */
	void update(Setmeal setmeal);

	/**
	 * 根据状态查询套餐
	 *
	 * @param status
	 * @return
	 */
	@Select("select * from setmeal where status = #{status}")
	List<Setmeal> list(Integer status);

}