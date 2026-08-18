package com.sky.controller.user;

import com.sky.entity.Category;
import com.sky.result.Result;
import com.sky.service.CategoryService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 用户端分类查询接口
 */
@RestController("userCategoryController")
@RequestMapping("/user/category")
@Slf4j
@Api(tags = "用户端分类查询接口")
public class CategoryController {

    @Autowired
    private CategoryService categoryService;

    /**
     * 查询分类列表
     *
     * @param type
     * @return
     */
    @GetMapping("/list")
    @ApiOperation("查询分类列表")
    public Result<List<Category>> list(Integer type) {
        // 将获取到的类型进行输出
        log.info("查询分类列表：{}", type);
        // 实现查询分类列表
        List<Category> list = categoryService.list(type);
        // 返回查询到的数据
        return Result.success(list);
    }

}
