package com.sky.mapper;

import com.github.pagehelper.Page;
import com.sky.dto.CategoryPageQueryDTO;
import com.sky.entity.Category;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface CategoryMapper {

    /**
     * 新增分类
     *
     * @param category
     */
	void insert(Category category);

    /**
     * 分类分页查询
     *
     * @param categoryPageQueryDTO
     * @return
     */
    Page<Category> pageQuery(CategoryPageQueryDTO categoryPageQueryDTO);

    /**
     * 根据id删除分类
     *
     * @param id
     */
    @Delete("delete from category where id = #{id}")
    void deleteById(Long id);

    /**
     * 根据id修改分类
     *
     * @param category
     */
    void update(Category category);

    /**
     * 根据id查询分类
     *
     * @param id
     * @return
     */
    @Select("select * from category where id = #{id}")
    Category getById(Long id);

    /**
     * 根据类型查询分类
     *
     * @param type
     * @return
     */
    @Select("select * from category where status = 1 and type = #{type} order by sort asc, create_time desc")
    java.util.List<Category> list(Integer type);

}
