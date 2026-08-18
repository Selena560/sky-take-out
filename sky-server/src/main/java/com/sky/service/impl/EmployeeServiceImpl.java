package com.sky.service.impl;

import com.github.pagehelper.Page;
import com.github.pagehelper.PageHelper;
import com.sky.constant.MessageConstant;
import com.sky.constant.StatusConstant;
import com.sky.context.BaseContext;
import com.sky.dto.EmployeeLoginDTO;
import com.sky.dto.EmployeeDTO;
import com.sky.dto.EmployeePageQueryDTO;
import com.sky.entity.Employee;
import com.sky.exception.AccountLockedException;
import com.sky.exception.AccountNotFoundException;
import com.sky.exception.PasswordErrorException;
import com.sky.mapper.EmployeeMapper;
import com.sky.result.PageResult;
import com.sky.service.EmployeeService;

import java.time.LocalDateTime;

import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;

@Service
public class EmployeeServiceImpl implements EmployeeService {

	@Autowired
	private EmployeeMapper employeeMapper;

	/**
	 * 员工登录
	 *
	 * @param employeeLoginDTO
	 * @return
	 */
	public Employee login(EmployeeLoginDTO employeeLoginDTO) {
		String username = employeeLoginDTO.getUsername();
		String password = employeeLoginDTO.getPassword();

		// 1、根据用户名查询数据库中的数据
		Employee employee = employeeMapper.getByUsername(username);

		// 2、处理各种异常情况（用户名不存在、密码不对、账号被锁定）
		if (employee == null) {
			// 账号不存在
			throw new AccountNotFoundException(MessageConstant.ACCOUNT_NOT_FOUND);
		}

		// 密码比对
		// TODO (todo提示信息，没有完成的内容加入，方便寻找)后期需要进行md5加密，然后再进行比对
		password = DigestUtils.md5DigestAsHex(password.getBytes());
		if (!password.equals(employee.getPassword())) {
			// 密码错误
			throw new PasswordErrorException(MessageConstant.PASSWORD_ERROR);
		}

		if (employee.getStatus() == StatusConstant.DISABLE) {
			// 账号被锁定
			throw new AccountLockedException(MessageConstant.ACCOUNT_LOCKED);
		}

		// 3、返回实体对象
		return employee;
	}

	/**
	 * 新增员工
	 *
	 * @param employeeDTO
	 */
	@Override
	public void save(EmployeeDTO employeeDTO) {
		// 创建一个Employee实体类对象
		Employee employee = new Employee();
		// 对象属性拷贝
		BeanUtils.copyProperties(employeeDTO, employee);
		// 设置账号状态，默认正常状态 1表示正常 0表示锁定
		employee.setStatus(StatusConstant.ENABLE);
		// 设置密码，默认密码123456
		employee.setPassword(DigestUtils.md5DigestAsHex("123456".getBytes()));
		// 设置当前记录创建时间和修改时间
		employee.setCreateTime(java.time.LocalDateTime.now());
		employee.setUpdateTime(java.time.LocalDateTime.now());
		// 设置当前记录创建人id和修改人idLong userId = BaseContext.getCurrentId();
		Long userId = BaseContext.getCurrentId();
		if (userId == null) {
            userId = 1L;  // 默认管理员id
        }
        employee.setCreateUser(userId);
        employee.setUpdateUser(userId);
        // 调用mapper层实现新增员工
		employeeMapper.insert(employee);
	}

	/**
	 * 员工分页查询
	 *
	 * @param employeePageQueryDTO
	 * @return
	 */
	@Override
	public PageResult pageQuery(EmployeePageQueryDTO employeePageQueryDTO) {
		// select * from employee limit 10,20
		// 开始分页，Spring中的工具
		PageHelper.startPage(employeePageQueryDTO.getPage(), employeePageQueryDTO.getPageSize());
		Page<Employee> page = employeeMapper.pageQuery(employeePageQueryDTO);
		return new PageResult(page.getTotal(), page.getResult());
	}

	/**
	 * 启用禁用员工账号
	 *
	 * @param status
	 * @param id
	 */
	@Override
	public void startOrStop(Integer status, Long id) {
		Employee employee = Employee.builder().status(status).id(id).build();
		employeeMapper.update(employee);
	}
	
	/**
	 * 根据id查询员工
	 *
	 * @param id
	 * @return
	 */
	@Override
	public Employee getById(Long id) {
	    // 调用mapper层实现根据id查询员工
	    return employeeMapper.getById(id);
	}

	/**
	 * 编辑员工信息
	 *
	 * @param employeeDTO
	 */
	@Override
	public void update(EmployeeDTO employeeDTO) {
	    // 创建一个Employee实体类对象
	    Employee employee = new Employee();
	    // 对象属性拷贝
	    BeanUtils.copyProperties(employeeDTO, employee);
	    // 设置修改时间和修改人
	    employee.setUpdateTime(LocalDateTime.now());
	    Long userId = BaseContext.getCurrentId();
	    if (userId == null) {
	        userId = 1L;
	    }
	    employee.setUpdateUser(userId);
	    // 调用mapper层实现编辑员工
	    employeeMapper.update(employee);
	}


}
