package com.sky.controller.admin;

import com.sky.dto.CategoryDTO;
import com.sky.dto.CategoryPageQueryDTO;
import com.sky.entity.Category;
import com.sky.result.PageResult;
import com.sky.result.Result;
import com.sky.service.CategoryService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 分类相关接口
 */
@RestController
@Slf4j	// 是一个log日志的效果（酸辣粉4j）
@Api(tags = "分类相关接口")	// 设置接口是干什么的中文名
@RequestMapping("/admin/category")
public class CategoryController {
	
	// 分类服务层接口实例化
	@Autowired
	private CategoryService categoryService;
	
	/**
	 * 新增分类
	 *
	 * @param categoryDTO
	 * @return
	 */
	@PostMapping
	@ApiOperation("新增分类")
	public Result save(@RequestBody CategoryDTO categoryDTO) {
		// 将获取到的实体类进行输出
		log.info("新增分类：{}", categoryDTO);	// 把值遍历到日志里面去，不会到工作台里面去
		
		// 实现新增分类
		categoryService.save(categoryDTO);
		// 返回新增成功的数据
		return Result.success();
	}
	
	/**
	 * 分类分页查询
	 *
	 * @param categoryPageQueryDTO
	 * @return
	 */
	@GetMapping("/page")
	@ApiOperation("分类分页查询")
	// 封装一个PageResult分页类型
	public Result<PageResult> page(CategoryPageQueryDTO categoryPageQueryDTO) {
		// 将获取到的实体类进行输出
		log.info("分页查询的实体类信息：{}", categoryPageQueryDTO);	// 把值遍历到日志里面去，不会到工作台里面去
		
		// 实现分页查询
		PageResult pageResult = categoryService.pageQuery(categoryPageQueryDTO);
		// 返回分页查询的数据
		return Result.success(pageResult);
	}
	
	/**
	 * 删除分类
	 *
	 * @param id
	 * @return
	 */
	@DeleteMapping
	@ApiOperation("删除分类")
	public Result deleteById(Long id) {
		// 将获取到的id进行输出
		log.info("删除分类：{}", id);	// 把值遍历到日志里面去，不会到工作台里面去
		
		// 实现删除分类
		categoryService.deleteById(id);
		// 返回删除成功的数据
		return Result.success();
	}
	
	/**
	 * 修改分类
	 *
	 * @param categoryDTO
	 * @return
	 */
	@PutMapping
	@ApiOperation("修改分类")
	public Result update(@RequestBody CategoryDTO categoryDTO) {
		// 将获取到的实体类进行输出
		log.info("修改分类：{}", categoryDTO);	// 把值遍历到日志里面去，不会到工作台里面去
		
		// 实现修改分类
		categoryService.update(categoryDTO);
		// 返回修改成功的数据
		return Result.success();
	}
	
	/**
	 * 启用禁用分类
	 *
	 * @param status
	 * @param id
	 * @return
	 */
	@PostMapping("/status/{status}")
	@ApiOperation("启用禁用分类")
	public Result startOrStop(@PathVariable("status") Integer status, Long id) {
		// 将获取到的状态以及id进行输出
		log.info("启用禁用分类：{},{}", status, id);	// 把值遍历到日志里面去，不会到工作台里面去
		
		// 实现启用禁用分类
		categoryService.startOrStop(status, id);
		// 返回启用禁用成功的数据
		return Result.success();
	}
	
	/**
	 * 根据类型查询分类
	 *
	 * @param type
	 * @return
	 */
	@GetMapping("/list")
	@ApiOperation("根据类型查询分类")
	public Result<List<Category>> list(Integer type) {
		// 将获取到的类型进行输出
		log.info("根据类型查询分类：{}", type);	// 把值遍历到日志里面去，不会到工作台里面去
		
		// 实现根据类型查询分类
		List<Category> list = categoryService.list(type);
		// 返回查询到的数据
		return Result.success(list);
	}
	
}