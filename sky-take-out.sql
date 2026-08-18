-- ============================================
-- Oracle 数据库适配版本 - 苍穹外卖 (sky_take_out)
-- 最终修复版：NOT NULL 和 DEFAULT 不能同时用于同一列
-- ============================================

-- ============================================
-- 删除已存在的对象（按依赖顺序）
-- ============================================
BEGIN
    FOR rec IN (SELECT trigger_name FROM user_triggers WHERE table_name IN ('ADDRESS_BOOK','CATEGORY','DISH','DISH_FLAVOR','EMPLOYEE','ORDER_DETAIL','ORDERS','SETMEAL','SETMEAL_DISH','SHOPPING_CART','USER_TABLE')) LOOP
        EXECUTE IMMEDIATE 'DROP TRIGGER ' || rec.trigger_name;
    END LOOP;
    FOR rec IN (SELECT sequence_name FROM user_sequences WHERE sequence_name LIKE 'SEQ_%') LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || rec.sequence_name;
    END LOOP;
    FOR rec IN (SELECT table_name FROM user_tables WHERE table_name IN ('ADDRESS_BOOK','CATEGORY','DISH','DISH_FLAVOR','EMPLOYEE','ORDER_DETAIL','ORDERS','SETMEAL','SETMEAL_DISH','SHOPPING_CART','USER_TABLE')) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || rec.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/

-- ============================================
-- 创建序列（用于自增主键）
-- ============================================
CREATE SEQUENCE SEQ_ADDRESS_BOOK START WITH 2 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_CATEGORY START WITH 23 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_DISH START WITH 70 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_DISH_FLAVOR START WITH 104 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_EMPLOYEE START WITH 2 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_ORDER_DETAIL START WITH 5 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_ORDERS START WITH 4 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_SETMEAL START WITH 32 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_SETMEAL_DISH START WITH 47 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_SHOPPING_CART START WITH 9 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_USER START WITH 4 INCREMENT BY 1 NOCACHE NOCYCLE;

-- ============================================
-- 1. 地址簿表 (address_book)
-- ============================================
CREATE TABLE address_book (
    id              NUMBER(19)      NOT NULL PRIMARY KEY,
    user_id         NUMBER(19)      NOT NULL,
    consignee       VARCHAR2(50),
    sex             VARCHAR2(2),
    phone           VARCHAR2(11)    NOT NULL,
    province_code   VARCHAR2(12),
    province_name   VARCHAR2(32),
    city_code       VARCHAR2(12),
    city_name       VARCHAR2(32),
    district_code   VARCHAR2(12),
    district_name   VARCHAR2(32),
    detail          VARCHAR2(200),
    label           VARCHAR2(100),
    is_default      NUMBER(1)       DEFAULT 0
);

COMMENT ON TABLE address_book IS '地址簿';
COMMENT ON COLUMN address_book.id IS '主键';
COMMENT ON COLUMN address_book.user_id IS '用户id';
COMMENT ON COLUMN address_book.consignee IS '收货人';
COMMENT ON COLUMN address_book.sex IS '性别';
COMMENT ON COLUMN address_book.phone IS '手机号';
COMMENT ON COLUMN address_book.province_code IS '省级区划编号';
COMMENT ON COLUMN address_book.province_name IS '省级名称';
COMMENT ON COLUMN address_book.city_code IS '市级区划编号';
COMMENT ON COLUMN address_book.city_name IS '市级名称';
COMMENT ON COLUMN address_book.district_code IS '区级区划编号';
COMMENT ON COLUMN address_book.district_name IS '区级名称';
COMMENT ON COLUMN address_book.detail IS '详细地址';
COMMENT ON COLUMN address_book.label IS '标签';
COMMENT ON COLUMN address_book.is_default IS '默认 0 否 1是';

CREATE OR REPLACE TRIGGER TRG_ADDRESS_BOOK
BEFORE INSERT ON address_book
FOR EACH ROW
BEGIN
    SELECT SEQ_ADDRESS_BOOK.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ============================================
-- 2. 分类表 (category)
-- ============================================
CREATE TABLE category (
    id          NUMBER(19)      NOT NULL PRIMARY KEY,
    type        NUMBER(10),
    name        VARCHAR2(32)    NOT NULL,
    sort        NUMBER(10)      DEFAULT 0,
    status      NUMBER(10),
    create_time DATE,
    update_time DATE,
    create_user NUMBER(19),
    update_user NUMBER(19)
);

COMMENT ON TABLE category IS '菜品及套餐分类';
COMMENT ON COLUMN category.id IS '主键';
COMMENT ON COLUMN category.type IS '类型 1 菜品分类 2 套餐分类';
COMMENT ON COLUMN category.name IS '分类名称';
COMMENT ON COLUMN category.sort IS '顺序';
COMMENT ON COLUMN category.status IS '分类状态 0:禁用，1:启用';
COMMENT ON COLUMN category.create_time IS '创建时间';
COMMENT ON COLUMN category.update_time IS '更新时间';
COMMENT ON COLUMN category.create_user IS '创建人';
COMMENT ON COLUMN category.update_user IS '修改人';

CREATE UNIQUE INDEX idx_category_name ON category(name);

CREATE OR REPLACE TRIGGER TRG_CATEGORY
BEFORE INSERT ON category
FOR EACH ROW
BEGIN
    SELECT SEQ_CATEGORY.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ============================================
-- 3. 菜品表 (dish)
-- ============================================
CREATE TABLE dish (
    id          NUMBER(19)      NOT NULL PRIMARY KEY,
    name        VARCHAR2(32)    NOT NULL,
    category_id NUMBER(19)      NOT NULL,
    price       NUMBER(10,2),
    image       VARCHAR2(255),
    description VARCHAR2(255),
    status      NUMBER(10)      DEFAULT 1,
    create_time DATE,
    update_time DATE,
    create_user NUMBER(19),
    update_user NUMBER(19)
);

COMMENT ON TABLE dish IS '菜品';
COMMENT ON COLUMN dish.id IS '主键';
COMMENT ON COLUMN dish.name IS '菜品名称';
COMMENT ON COLUMN dish.category_id IS '菜品分类id';
COMMENT ON COLUMN dish.price IS '菜品价格';
COMMENT ON COLUMN dish.image IS '图片';
COMMENT ON COLUMN dish.description IS '描述信息';
COMMENT ON COLUMN dish.status IS '0 停售 1 起售';
COMMENT ON COLUMN dish.create_time IS '创建时间';
COMMENT ON COLUMN dish.update_time IS '更新时间';
COMMENT ON COLUMN dish.create_user IS '创建人';
COMMENT ON COLUMN dish.update_user IS '修改人';

CREATE UNIQUE INDEX idx_dish_name ON dish(name);

CREATE OR REPLACE TRIGGER TRG_DISH
BEFORE INSERT ON dish
FOR EACH ROW
BEGIN
    SELECT SEQ_DISH.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ============================================
-- 4. 菜品口味表 (dish_flavor)
-- ============================================
CREATE TABLE dish_flavor (
    id      NUMBER(19)      NOT NULL PRIMARY KEY,
    dish_id NUMBER(19)      NOT NULL,
    name    VARCHAR2(32),
    value   VARCHAR2(255)
);

COMMENT ON TABLE dish_flavor IS '菜品口味关系表';
COMMENT ON COLUMN dish_flavor.id IS '主键';
COMMENT ON COLUMN dish_flavor.dish_id IS '菜品';
COMMENT ON COLUMN dish_flavor.name IS '口味名称';
COMMENT ON COLUMN dish_flavor.value IS '口味数据list';

CREATE OR REPLACE TRIGGER TRG_DISH_FLAVOR
BEFORE INSERT ON dish_flavor
FOR EACH ROW
BEGIN
    SELECT SEQ_DISH_FLAVOR.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ============================================
-- 5. 员工表 (employee)
-- ============================================
CREATE TABLE employee (
    id          NUMBER(19)      NOT NULL PRIMARY KEY,
    name        VARCHAR2(32)    NOT NULL,
    username    VARCHAR2(32)    NOT NULL,
    password    VARCHAR2(64)    NOT NULL,
    phone       VARCHAR2(11)    NOT NULL,
    sex         VARCHAR2(2)     NOT NULL,
    id_number   VARCHAR2(18)    NOT NULL,
    status      NUMBER(10)      DEFAULT 1,
    create_time DATE,
    update_time DATE,
    create_user NUMBER(19),
    update_user NUMBER(19)
);

COMMENT ON TABLE employee IS '员工信息';
COMMENT ON COLUMN employee.id IS '主键';
COMMENT ON COLUMN employee.name IS '姓名';
COMMENT ON COLUMN employee.username IS '用户名';
COMMENT ON COLUMN employee.password IS '密码';
COMMENT ON COLUMN employee.phone IS '手机号';
COMMENT ON COLUMN employee.sex IS '性别';
COMMENT ON COLUMN employee.id_number IS '身份证号';
COMMENT ON COLUMN employee.status IS '状态 0:禁用，1:启用';
COMMENT ON COLUMN employee.create_time IS '创建时间';
COMMENT ON COLUMN employee.update_time IS '更新时间';
COMMENT ON COLUMN employee.create_user IS '创建人';
COMMENT ON COLUMN employee.update_user IS '修改人';

CREATE UNIQUE INDEX idx_username ON employee(username);

CREATE OR REPLACE TRIGGER TRG_EMPLOYEE
BEFORE INSERT ON employee
FOR EACH ROW
BEGIN
    SELECT SEQ_EMPLOYEE.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ============================================
-- 6. 订单明细表 (order_detail)
-- ============================================
CREATE TABLE order_detail (
    id          NUMBER(19)      NOT NULL PRIMARY KEY,
    name        VARCHAR2(32),
    image       VARCHAR2(255),
    order_id    NUMBER(19)      NOT NULL,
    dish_id     NUMBER(19),
    setmeal_id  NUMBER(19),
    dish_flavor VARCHAR2(50),
    num         NUMBER(10)      DEFAULT 1,
    amount      NUMBER(10,2)    NOT NULL
);

COMMENT ON TABLE order_detail IS '订单明细表';
COMMENT ON COLUMN order_detail.id IS '主键';
COMMENT ON COLUMN order_detail.name IS '名字';
COMMENT ON COLUMN order_detail.image IS '图片';
COMMENT ON COLUMN order_detail.order_id IS '订单id';
COMMENT ON COLUMN order_detail.dish_id IS '菜品id';
COMMENT ON COLUMN order_detail.setmeal_id IS '套餐id';
COMMENT ON COLUMN order_detail.dish_flavor IS '口味';
COMMENT ON COLUMN order_detail.num IS '数量';
COMMENT ON COLUMN order_detail.amount IS '金额';

CREATE OR REPLACE TRIGGER TRG_ORDER_DETAIL
BEFORE INSERT ON order_detail
FOR EACH ROW
BEGIN
    SELECT SEQ_ORDER_DETAIL.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ============================================
-- 7. 订单表 (orders)
-- ============================================
CREATE TABLE orders (
    id                      NUMBER(19)      NOT NULL PRIMARY KEY,
    order_num               VARCHAR2(50),
    status                  NUMBER(10)      DEFAULT 1,
    user_id                 NUMBER(19)      NOT NULL,
    address_book_id         NUMBER(19)      NOT NULL,
    order_time              DATE            NOT NULL,
    checkout_time           DATE,
    pay_method              NUMBER(10)      DEFAULT 1,
    pay_status              NUMBER(3)       DEFAULT 0,
    amount                  NUMBER(10,2)    NOT NULL,
    remark                  VARCHAR2(100),
    phone                   VARCHAR2(11),
    address                 VARCHAR2(255),
    user_name               VARCHAR2(32),
    consignee               VARCHAR2(32),
    cancel_reason           VARCHAR2(255),
    rejection_reason        VARCHAR2(255),
    cancel_time             DATE,
    estimated_delivery_time DATE,
    delivery_status         NUMBER(1)       DEFAULT 1,
    delivery_time           DATE,
    pack_amount             NUMBER(10),
    tableware_num           NUMBER(10),
    tableware_status        NUMBER(1)       DEFAULT 1
);

COMMENT ON TABLE orders IS '订单表';
COMMENT ON COLUMN orders.id IS '主键';
COMMENT ON COLUMN orders.order_num IS '订单号';
COMMENT ON COLUMN orders.status IS '订单状态 1待付款 2待接单 3已接单 4派送中 5已完成 6已取消 7退款';
COMMENT ON COLUMN orders.user_id IS '下单用户';
COMMENT ON COLUMN orders.address_book_id IS '地址id';
COMMENT ON COLUMN orders.order_time IS '下单时间';
COMMENT ON COLUMN orders.checkout_time IS '结账时间';
COMMENT ON COLUMN orders.pay_method IS '支付方式 1微信,2支付宝';
COMMENT ON COLUMN orders.pay_status IS '支付状态 0未支付 1已支付 2退款';
COMMENT ON COLUMN orders.amount IS '实收金额';
COMMENT ON COLUMN orders.remark IS '备注';
COMMENT ON COLUMN orders.phone IS '手机号';
COMMENT ON COLUMN orders.address IS '地址';
COMMENT ON COLUMN orders.user_name IS '用户名称';
COMMENT ON COLUMN orders.consignee IS '收货人';
COMMENT ON COLUMN orders.cancel_reason IS '订单取消原因';
COMMENT ON COLUMN orders.rejection_reason IS '订单拒绝原因';
COMMENT ON COLUMN orders.cancel_time IS '订单取消时间';
COMMENT ON COLUMN orders.estimated_delivery_time IS '预计送达时间';
COMMENT ON COLUMN orders.delivery_status IS '配送状态 1立即送出 0选择具体时间';
COMMENT ON COLUMN orders.delivery_time IS '送达时间';
COMMENT ON COLUMN orders.pack_amount IS '打包费';
COMMENT ON COLUMN orders.tableware_num IS '餐具数量';
COMMENT ON COLUMN orders.tableware_status IS '餐具数量状态 1按餐量提供 0选择具体数量';

CREATE OR REPLACE TRIGGER TRG_ORDERS
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    SELECT SEQ_ORDERS.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ============================================
-- 8. 套餐表 (setmeal)
-- ============================================
CREATE TABLE setmeal (
    id          NUMBER(19)      NOT NULL PRIMARY KEY,
    category_id NUMBER(19)      NOT NULL,
    name        VARCHAR2(32)    NOT NULL,
    price       NUMBER(10,2)    NOT NULL,
    status      NUMBER(10)      DEFAULT 1,
    description VARCHAR2(255),
    image       VARCHAR2(255),
    create_time DATE,
    update_time DATE,
    create_user NUMBER(19),
    update_user NUMBER(19)
);

COMMENT ON TABLE setmeal IS '套餐';
COMMENT ON COLUMN setmeal.id IS '主键';
COMMENT ON COLUMN setmeal.category_id IS '菜品分类id';
COMMENT ON COLUMN setmeal.name IS '套餐名称';
COMMENT ON COLUMN setmeal.price IS '套餐价格';
COMMENT ON COLUMN setmeal.status IS '售卖状态 0:停售 1:起售';
COMMENT ON COLUMN setmeal.description IS '描述信息';
COMMENT ON COLUMN setmeal.image IS '图片';
COMMENT ON COLUMN setmeal.create_time IS '创建时间';
COMMENT ON COLUMN setmeal.update_time IS '更新时间';
COMMENT ON COLUMN setmeal.create_user IS '创建人';
COMMENT ON COLUMN setmeal.update_user IS '修改人';

CREATE UNIQUE INDEX idx_setmeal_name ON setmeal(name);

CREATE OR REPLACE TRIGGER TRG_SETMEAL
BEFORE INSERT ON setmeal
FOR EACH ROW
BEGIN
    SELECT SEQ_SETMEAL.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ============================================
-- 9. 套餐菜品关系表 (setmeal_dish)
-- ============================================
CREATE TABLE setmeal_dish (
    id          NUMBER(19)      NOT NULL PRIMARY KEY,
    setmeal_id  NUMBER(19),
    dish_id     NUMBER(19),
    name        VARCHAR2(32),
    price       NUMBER(10,2),
    copies      NUMBER(10)
);

COMMENT ON TABLE setmeal_dish IS '套餐菜品关系';
COMMENT ON COLUMN setmeal_dish.id IS '主键';
COMMENT ON COLUMN setmeal_dish.setmeal_id IS '套餐id';
COMMENT ON COLUMN setmeal_dish.dish_id IS '菜品id';
COMMENT ON COLUMN setmeal_dish.name IS '菜品名称（冗余字段）';
COMMENT ON COLUMN setmeal_dish.price IS '菜品单价（冗余字段）';
COMMENT ON COLUMN setmeal_dish.copies IS '菜品份数';

CREATE OR REPLACE TRIGGER TRG_SETMEAL_DISH
BEFORE INSERT ON setmeal_dish
FOR EACH ROW
BEGIN
    SELECT SEQ_SETMEAL_DISH.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ============================================
-- 10. 购物车表 (shopping_cart)
-- ============================================
CREATE TABLE shopping_cart (
    id          NUMBER(19)      NOT NULL PRIMARY KEY,
    name        VARCHAR2(32),
    image       VARCHAR2(255),
    user_id     NUMBER(19)      NOT NULL,
    dish_id     NUMBER(19),
    setmeal_id  NUMBER(19),
    dish_flavor VARCHAR2(50),
    num         NUMBER(10)      DEFAULT 1,
    amount      NUMBER(10,2)    NOT NULL,
    create_time DATE
);

COMMENT ON TABLE shopping_cart IS '购物车';
COMMENT ON COLUMN shopping_cart.id IS '主键';
COMMENT ON COLUMN shopping_cart.name IS '商品名称';
COMMENT ON COLUMN shopping_cart.image IS '图片';
COMMENT ON COLUMN shopping_cart.user_id IS '用户id';
COMMENT ON COLUMN shopping_cart.dish_id IS '菜品id';
COMMENT ON COLUMN shopping_cart.setmeal_id IS '套餐id';
COMMENT ON COLUMN shopping_cart.dish_flavor IS '口味';
COMMENT ON COLUMN shopping_cart.num IS '数量';
COMMENT ON COLUMN shopping_cart.amount IS '金额';
COMMENT ON COLUMN shopping_cart.create_time IS '创建时间';

CREATE OR REPLACE TRIGGER TRG_SHOPPING_CART
BEFORE INSERT ON shopping_cart
FOR EACH ROW
BEGIN
    SELECT SEQ_SHOPPING_CART.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ============================================
-- 11. 用户表 (user_table)
-- ============================================
CREATE TABLE user_table (
    id          NUMBER(19)      NOT NULL PRIMARY KEY,
    openid      VARCHAR2(45),
    name        VARCHAR2(32),
    phone       VARCHAR2(11),
    sex         VARCHAR2(2),
    id_number   VARCHAR2(18),
    avatar      VARCHAR2(500),
    create_time DATE
);

COMMENT ON TABLE user_table IS '用户信息';
COMMENT ON COLUMN user_table.id IS '主键';
COMMENT ON COLUMN user_table.openid IS '微信用户唯一标识';
COMMENT ON COLUMN user_table.name IS '姓名';
COMMENT ON COLUMN user_table.phone IS '手机号';
COMMENT ON COLUMN user_table.sex IS '性别';
COMMENT ON COLUMN user_table.id_number IS '身份证号';
COMMENT ON COLUMN user_table.avatar IS '头像';
COMMENT ON COLUMN user_table.create_time IS '注册时间';

CREATE OR REPLACE TRIGGER TRG_USER_TABLE
BEFORE INSERT ON user_table
FOR EACH ROW
BEGIN
    SELECT SEQ_USER.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

-- ============================================
-- 插入初始数据
-- ============================================

-- category 数据
INSERT INTO category (id, type, name, sort, status, create_time, update_time, create_user, update_user) VALUES (11, 1, '酒水饮料', 10, 1, TO_DATE('2022-06-09 22:09:18', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-09 22:09:18', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO category (id, type, name, sort, status, create_time, update_time, create_user, update_user) VALUES (12, 1, '传统主食', 9, 1, TO_DATE('2022-06-09 22:09:32', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 11:04:40', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO category (id, type, name, sort, status, create_time, update_time, create_user, update_user) VALUES (13, 2, '人气套餐', 12, 1, TO_DATE('2022-06-09 22:11:38', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 11:04:40', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO category (id, type, name, sort, status, create_time, update_time, create_user, update_user) VALUES (15, 2, '商务套餐', 13, 1, TO_DATE('2022-06-09 22:14:10', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 11:04:48', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO category (id, type, name, sort, status, create_time, update_time, create_user, update_user) VALUES (16, 1, '蜀味烤鱼', 4, 1, TO_DATE('2022-06-09 22:15:37', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-08-31 14:27:25', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO category (id, type, name, sort, status, create_time, update_time, create_user, update_user) VALUES (17, 1, '蜀味牛蛙', 5, 1, TO_DATE('2022-06-09 22:16:14', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-08-31 14:39:44', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO category (id, type, name, sort, status, create_time, update_time, create_user, update_user) VALUES (18, 1, '特色蒸菜', 6, 1, TO_DATE('2022-06-09 22:17:42', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-09 22:17:42', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO category (id, type, name, sort, status, create_time, update_time, create_user, update_user) VALUES (19, 1, '新鲜时蔬', 7, 1, TO_DATE('2022-06-09 22:18:12', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-09 22:18:28', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO category (id, type, name, sort, status, create_time, update_time, create_user, update_user) VALUES (20, 1, '水煮鱼', 8, 1, TO_DATE('2022-06-09 22:22:29', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-09 22:23:45', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO category (id, type, name, sort, status, create_time, update_time, create_user, update_user) VALUES (21, 1, '汤类', 11, 1, TO_DATE('2022-06-10 10:51:47', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:51:47', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);

-- dish 数据
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (46, '王老吉', 11, 6.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/41bfcacf-7ad4-4927-8b26-df366553a94c.png', '', 1, TO_DATE('2022-06-09 22:40:47', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-09 22:40:47', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (47, '北冰洋', 11, 4.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/4451d4be-89a2-4939-9c69-3a87151cb979.png', '还是小时候的味道', 1, TO_DATE('2022-06-10 09:18:49', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 09:18:49', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (48, '雪花啤酒', 11, 4.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/bf8cbfc1-04d2-40e8-9826-061ee41ab87c.png', '', 1, TO_DATE('2022-06-10 09:22:54', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 09:22:54', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (49, '米饭', 12, 2.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/76752350-2121-44d2-b477-10791c23a8ec.png', '精选五常大米', 1, TO_DATE('2022-06-10 09:30:17', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 09:30:17', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (50, '馒头', 12, 1.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/475cc599-8661-4899-8f9e-121dd8ef7d02.png', '优质面粉', 1, TO_DATE('2022-06-10 09:34:28', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 09:34:28', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (51, '老坛酸菜鱼', 20, 56.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/4a9cefba-6a74-467e-9fde-6e687ea725d7.png', '原料：汤，草鱼，酸菜', 1, TO_DATE('2022-06-10 09:40:51', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 09:40:51', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (52, '经典酸菜鮰鱼', 20, 66.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/5260ff39-986c-4a97-8850-2ec8c7583efc.png', '原料：酸菜，江团，鮰鱼', 1, TO_DATE('2022-06-10 09:46:02', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 09:46:02', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (53, '蜀味水煮草鱼', 20, 38.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/a6953d5a-4c18-4b30-9319-4926ee77261f.png', '原料：草鱼，汤', 1, TO_DATE('2022-06-10 09:48:37', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 09:48:37', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (54, '清炒小油菜', 19, 18.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/3613d38e-5614-41c2-90ed-ff175bf50716.png', '原料：小油菜', 1, TO_DATE('2022-06-10 09:51:46', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 09:51:46', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (55, '蒜蓉娃娃菜', 19, 18.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/4879ed66-3860-4b28-ba14-306ac025fdec.png', '原料：蒜，娃娃菜', 1, TO_DATE('2022-06-10 09:53:37', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 09:53:37', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (56, '清炒西兰花', 19, 18.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/e9ec4ba4-4b22-4fc8-9be0-4946e6aeb937.png', '原料：西兰花', 1, TO_DATE('2022-06-10 09:55:44', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 09:55:44', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (57, '炝炒圆白菜', 19, 18.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/22f59feb-0d44-430e-a6cd-6a49f27453ca.png', '原料：圆白菜', 1, TO_DATE('2022-06-10 09:58:35', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 09:58:35', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (58, '清蒸鲈鱼', 18, 98.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/c18b5c67-3b71-466c-a75a-e63c6449f21c.png', '原料：鲈鱼', 1, TO_DATE('2022-06-10 10:12:28', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:12:28', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (59, '东坡肘子', 18, 138.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/a80a4b8c-c93e-4f43-ac8a-856b0d5cc451.png', '原料：猪肘棒', 1, TO_DATE('2022-06-10 10:24:03', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:24:03', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (60, '梅菜扣肉', 18, 58.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/6080b118-e30a-4577-aab4-45042e3f88be.png', '原料：猪肉，梅菜', 1, TO_DATE('2022-06-10 10:26:03', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:26:03', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (61, '剁椒鱼头', 18, 66.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/13da832f-ef2c-484d-8370-5934a1045a06.png', '原料：鲢鱼，剁椒', 1, TO_DATE('2022-06-10 10:28:54', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:28:54', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (62, '金汤酸菜牛蛙', 17, 88.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/7694a5d8-7938-4e9d-8b9e-2075983a2e38.png', '原料：鲜活牛蛙，酸菜', 1, TO_DATE('2022-06-10 10:33:05', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:33:05', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (63, '香锅牛蛙', 17, 88.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/f5ac8455-4793-450c-97ba-173795c34626.png', '配料：鲜活牛蛙，莲藕，青笋', 1, TO_DATE('2022-06-10 10:35:40', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:35:40', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (64, '馋嘴牛蛙', 17, 88.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/7a55b845-1f2b-41fa-9486-76d187ee9ee1.png', '配料：鲜活牛蛙，丝瓜，黄豆芽', 1, TO_DATE('2022-06-10 10:37:52', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:37:52', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (65, '草鱼2斤', 16, 68.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/b544d3ba-a1ae-4d20-a860-81cb5dec9e03.png', '原料：草鱼，黄豆芽，莲藕', 1, TO_DATE('2022-06-10 10:41:08', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:41:08', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (66, '江团鱼2斤', 16, 119.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/a101a1e9-8f8b-47b2-afa4-1abd47ea0a87.png', '配料：江团鱼，黄豆芽，莲藕', 1, TO_DATE('2022-06-10 10:42:42', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:42:42', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (67, '鮰鱼2斤', 16, 72.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/8cfcc576-4b66-4a09-ac68-ad5b273c2590.png', '原料：鮰鱼，黄豆芽，莲藕', 1, TO_DATE('2022-06-10 10:43:56', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:43:56', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (68, '鸡蛋汤', 21, 4.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/c09a0ee8-9d19-428d-81b9-746221824113.png', '配料：鸡蛋，紫菜', 1, TO_DATE('2022-06-10 10:54:25', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:54:25', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);
INSERT INTO dish (id, name, category_id, price, image, description, status, create_time, update_time, create_user, update_user) VALUES (69, '平菇豆腐汤', 21, 6.00, 'https://sky-itcast.oss-cn-beijing.aliyuncs.com/16d0a3d6-2253-4cfc-9b49-bf7bd9eb2ad2.png', '配料：豆腐，平菇', 1, TO_DATE('2022-06-10 10:55:02', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-06-10 10:55:02', 'YYYY-MM-DD HH24:MI:SS'), 1, 1);

-- dish_flavor 数据
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (40, 10, '甜味', '["无糖","少糖","半糖","多糖","全糖"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (41, 7, '忌口', '["不要葱","不要蒜","不要香菜","不要辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (42, 7, '温度', '["热饮","常温","去冰","少冰","多冰"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (45, 6, '忌口', '["不要葱","不要蒜","不要香菜","不要辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (46, 6, '辣度', '["不辣","微辣","中辣","重辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (47, 5, '辣度', '["不辣","微辣","中辣","重辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (48, 5, '甜味', '["无糖","少糖","半糖","多糖","全糖"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (49, 2, '甜味', '["无糖","少糖","半糖","多糖","全糖"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (50, 4, '甜味', '["无糖","少糖","半糖","多糖","全糖"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (51, 3, '甜味', '["无糖","少糖","半糖","多糖","全糖"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (52, 3, '忌口', '["不要葱","不要蒜","不要香菜","不要辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (86, 52, '忌口', '["不要葱","不要蒜","不要香菜","不要辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (87, 52, '辣度', '["不辣","微辣","中辣","重辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (88, 51, '忌口', '["不要葱","不要蒜","不要香菜","不要辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (89, 51, '辣度', '["不辣","微辣","中辣","重辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (92, 53, '忌口', '["不要葱","不要蒜","不要香菜","不要辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (93, 53, '辣度', '["不辣","微辣","中辣","重辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (94, 54, '忌口', '["不要葱","不要蒜","不要香菜"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (95, 56, '忌口', '["不要葱","不要蒜","不要香菜","不要辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (96, 57, '忌口', '["不要葱","不要蒜","不要香菜","不要辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (97, 60, '忌口', '["不要葱","不要蒜","不要香菜","不要辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (101, 66, '辣度', '["不辣","微辣","中辣","重辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (102, 67, '辣度', '["不辣","微辣","中辣","重辣"]');
INSERT INTO dish_flavor (id, dish_id, name, value) VALUES (103, 65, '辣度', '["不辣","微辣","中辣","重辣"]');

-- employee 数据
INSERT INTO employee (id, name, username, password, phone, sex, id_number, status, create_time, update_time, create_user, update_user) VALUES (1, '管理员', 'admin', '123456', '13812312312', '1', '110101199001010047', 1, TO_DATE('2022-02-15 15:51:20', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2022-02-17 09:16:20', 'YYYY-MM-DD HH24:MI:SS'), 10, 1);

COMMIT;


