package com.sky.handler;

import com.sky.constant.MessageConstant;
import com.sky.exception.BaseException;
import com.sky.exception.DeletionNotAllowedException;
import com.sky.result.Result;
import lombok.extern.slf4j.Slf4j;

import java.sql.SQLIntegrityConstraintViolationException;

import org.apache.xmlbeans.impl.piccolo.util.DuplicateKeyException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理器，处理项目中抛出的业务异常
 */
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    /**
     * 捕获业务异常
     * @param ex
     * @return
     */
    @ExceptionHandler
    public Result exceptionHandler(BaseException ex){
        log.error("异常信息：{}", ex.getMessage());
        return Result.error(ex.getMessage());
    }

    /**
     * 捕获删除不允许异常
     *
     * @param ex
     * @return
     */
    @ExceptionHandler
    public Result exceptionHandler(DeletionNotAllowedException ex) {
        log.error("异常信息：{}", ex.getMessage());
        return Result.error(ex.getMessage());
    }


    /**
     * 捕获重复键异常（Oracle等）
     *
     * @param ex
     * @return
     */
    @ExceptionHandler
    public Result exceptionHandler(DuplicateKeyException ex) {
        log.error("异常信息：{}", ex.getMessage());
        String message = ex.getMessage();
        if (message.contains("IDX_CATEGORY_NAME") || message.contains("unique constraint")) {
            return Result.error("分类名称已存在");
        }
        if (message.contains("employee") || message.contains("USERNAME")) {
            return Result.error("用户名已存在");
        }
        return Result.error(MessageConstant.UNKNOWN_ERROR);
    }

}