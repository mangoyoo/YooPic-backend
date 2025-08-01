create database if not exists `yoo_pic` default character set utf8mb4 collate utf8mb4_unicode_ci;

use yoo_pic;
-- 用户表
create table if not exists user
(
    id           bigint auto_increment comment 'id' primary key,
    userAccount  varchar(256)                           not null comment '账号',
    userPassword varchar(512)                           not null comment '密码',
    userName     varchar(256)                           null comment '用户昵称',
    userAvatar   varchar(1024)                          null comment '用户头像',
    userProfile  varchar(512)                           null comment '用户简介',
    userRole     varchar(256) default 'user'            not null comment '用户角色：user/admin',
    editTime     datetime     default CURRENT_TIMESTAMP not null comment '编辑时间',
    createTime   datetime     default CURRENT_TIMESTAMP not null comment '创建时间',
    updateTime   datetime     default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    isDelete     tinyint      default 0                 not null comment '是否删除',
    UNIQUE KEY uk_userAccount (userAccount),
    INDEX idx_userName (userName)
) comment '用户' collate = utf8mb4_unicode_ci;

-- 图片表
create table if not exists picture
(
    id           bigint auto_increment comment 'id' primary key,
    url          varchar(512)                       not null comment '图片 url',
    name         varchar(128)                       not null comment '图片名称',
    introduction varchar(512)                       null comment '简介',
    category     varchar(64)                        null comment '分类',
    tags         varchar(512)                      null comment '标签（JSON 数组）',
    picSize      bigint                             null comment '图片体积',
    picWidth     int                                null comment '图片宽度',
    picHeight    int                                null comment '图片高度',
    picScale     double                             null comment '图片宽高比例',
    picFormat    varchar(32)                        null comment '图片格式',
    userId       bigint                             not null comment '创建用户 id',
    createTime   datetime default CURRENT_TIMESTAMP not null comment '创建时间',
    editTime     datetime default CURRENT_TIMESTAMP not null comment '编辑时间',
    updateTime   datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    isDelete     tinyint  default 0                 not null comment '是否删除',
    INDEX idx_name (name),                 -- 提升基于图片名称的查询性能
    INDEX idx_introduction (introduction), -- 用于模糊搜索图片简介
    INDEX idx_category (category),         -- 提升基于分类的查询性能
    INDEX idx_tags (tags),                 -- 提升基于标签的查询性能
    INDEX idx_userId (userId)              -- 提升基于用户 ID 的查询性能
) comment '图片' collate = utf8mb4_unicode_ci;


ALTER TABLE picture
    -- 添加新列
    ADD COLUMN reviewStatus INT DEFAULT 0 NOT NULL COMMENT '审核状态：0-待审核; 1-通过; 2-拒绝',
    ADD COLUMN reviewMessage VARCHAR(512) NULL COMMENT '审核信息',
    ADD COLUMN reviewerId BIGINT NULL COMMENT '审核人 ID',
    ADD COLUMN reviewTime DATETIME NULL COMMENT '审核时间';

-- 创建基于 reviewStatus 列的索引
CREATE INDEX idx_reviewStatus ON picture (reviewStatus);
ALTER TABLE picture
    -- 添加新列
    ADD COLUMN thumbnailUrl varchar(512) NULL COMMENT '缩略图 url';
-- 空间表
create table if not exists space
(
    id         bigint auto_increment comment 'id' primary key,
    spaceName  varchar(128)                       null comment '空间名称',
    spaceLevel int      default 0                 null comment '空间级别：0-普通版 1-专业版 2-旗舰版',
    maxSize    bigint   default 0                 null comment '空间图片的最大总大小',
    maxCount   bigint   default 0                 null comment '空间图片的最大数量',
    totalSize  bigint   default 0                 null comment '当前空间下图片的总大小',
    totalCount bigint   default 0                 null comment '当前空间下的图片数量',
    userId     bigint                             not null comment '创建用户 id',
    createTime datetime default CURRENT_TIMESTAMP not null comment '创建时间',
    editTime   datetime default CURRENT_TIMESTAMP not null comment '编辑时间',
    updateTime datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    isDelete   tinyint  default 0                 not null comment '是否删除',
    -- 索引设计
    index idx_userId (userId),        -- 提升基于用户的查询效率
    index idx_spaceName (spaceName),  -- 提升基于空间名称的查询效率
    index idx_spaceLevel (spaceLevel) -- 提升按空间级别查询的效率
) comment '空间' collate = utf8mb4_unicode_ci;
-- 添加新列
ALTER TABLE picture
    ADD COLUMN spaceId  bigint  null comment '空间 id（为空表示公共空间）';

-- 创建索引
CREATE INDEX idx_spaceId ON picture (spaceId);
ALTER TABLE picture
    ADD COLUMN picColor varchar(16) null comment '图片主色调';
ALTER TABLE space
    ADD COLUMN spaceType int default 0 not null comment '空间类型：0-私有 1-团队';

CREATE INDEX idx_spaceType ON space (spaceType);
-- 空间成员表
create table if not exists space_user
(
    id         bigint auto_increment comment 'id' primary key,
    spaceId    bigint                                 not null comment '空间 id',
    userId     bigint                                 not null comment '用户 id',
    spaceRole  varchar(128) default 'viewer'          null comment '空间角色：viewer/editor/admin',
    createTime datetime     default CURRENT_TIMESTAMP not null comment '创建时间',
    updateTime datetime     default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    -- 索引设计
    UNIQUE KEY uk_spaceId_userId (spaceId, userId), -- 唯一索引，用户在一个空间中只能有一个角色
    INDEX idx_spaceId (spaceId),                    -- 提升按空间查询的性能
    INDEX idx_userId (userId)                       -- 提升按用户查询的性能
) comment '空间用户关联' collate = utf8mb4_unicode_ci;




# -- 1. 首先创建与 picture 表结构相同的新表 new_picture
# CREATE TABLE new_picture LIKE picture;
#
# -- 2. 按照 createTime 降序插入数据（最新的优先）
# INSERT INTO new_picture
# SELECT * FROM picture
# ORDER BY createTime DESC;
#
#
#
# -- 1. 将原 picture 表重命名为 old_picture（作为备份）
# RENAME TABLE picture TO old_picture;
#
# -- 2. 将 new_picture 表重命名为 picture（恢复原表名）
# RENAME TABLE new_picture TO picture;

# -- 1. 创建新表，结构与picture表相同
# CREATE TABLE new_picture LIKE picture;
#
# -- 2. 重置主键自增设置（确保从1开始）
# ALTER TABLE new_picture AUTO_INCREMENT = 1;
#
# -- 3. 按createTime降序将picture表中的数据插入到new_picture表中
# INSERT INTO new_picture (
#     url, name, introduction, category, tags, picSize, picWidth, picHeight,
#     picScale, picFormat, userId, createTime, editTime, updateTime, isDelete,
#     reviewStatus, reviewMessage, reviewerId, reviewTime, thumbnailUrl,
#     spaceId, picColor
# )
# SELECT
#     url, name, introduction, category, tags, picSize, picWidth, picHeight,
#     picScale, picFormat, userId, createTime, editTime, updateTime, isDelete,
#     reviewStatus, reviewMessage, reviewerId, reviewTime, thumbnailUrl,
#     spaceId, picColor
# FROM picture
# ORDER BY createTime DESC;
#
# -- 4. 检查新表是否正确
# SELECT * FROM new_picture LIMIT 5;

-- 5. 如果一切正常，可以重命名表
-- RENAME TABLE picture TO old_picture;
-- RENAME TABLE new_picture TO picture;


# CREATE TABLE `pic_time` (
#                             `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
#                             `createTime` datetime DEFAULT NULL COMMENT '创建时间',
#                             `editTime` datetime DEFAULT NULL COMMENT '编辑时间',
#                             `updateTime` datetime DEFAULT NULL COMMENT '更新时间',
#                             `reviewTime` datetime DEFAULT NULL COMMENT '审核时间',
#                             PRIMARY KEY (`id`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='图片时间信息';
#
#
#
# INSERT INTO pic_time2 (createTime, editTime, updateTime, reviewTime)
# SELECT createTime, editTime, updateTime, reviewTime
# FROM picture
# ORDER BY createTime ASC;
#
#
#
# -- 为每个记录创建一个临时表，包含原始ID和排序后的行号
# CREATE TEMPORARY TABLE ordered_pictures AS
# SELECT
#     @row_num := @row_num + 1 AS row_num,
#     id AS original_id
# FROM
#     picture,
#     (SELECT @row_num := 0) AS r
# ORDER BY
#     createTime ASC;
#
# -- 使用临时表进行更新，并添加明确的WHERE条件
# UPDATE picture p
#     INNER JOIN ordered_pictures op ON p.id = op.original_id
#     INNER JOIN pic_time2 pt ON op.row_num = pt.id
# SET
#     p.createTime = pt.createTime,
#     p.editTime = pt.editTime,
#     p.updateTime = pt.updateTime,
#     p.reviewTime = pt.reviewTime
# WHERE p.id = op.original_id;  -- 显式WHERE条件
#
# -- 清理临时表
# DROP TEMPORARY TABLE IF EXISTS ordered_pictures;
#
#
#
# -- 1. 复制表结构（包括索引、约束等）
# CREATE TABLE picture_copy LIKE picture;
#
# -- 2. 复制数据
# INSERT INTO picture_copy SELECT * FROM picture;
#
#
# -- 创建 pic_time 表
# CREATE TABLE `pic_time` (
#                             `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'id',
#                             `createTime` datetime DEFAULT NULL COMMENT '创建时间',
#                             `editTime` datetime DEFAULT NULL COMMENT '编辑时间',
#                             `updateTime` datetime DEFAULT NULL COMMENT '更新时间',
#                             `reviewTime` datetime DEFAULT NULL COMMENT '审核时间',
#                             PRIMARY KEY (`id`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='图片时间信息';
#
# -- 从 picture 表查询数据并插入到 pic_time 表
# INSERT INTO pic_time (createTime, editTime, updateTime, reviewTime)
# SELECT createTime, editTime, updateTime, reviewTime
# FROM picture
# ORDER BY createTime ASC;
#
#
# -- 更新 picture_copy 表中的时间字段，根据 pic_time 中对应 id 的记录
# UPDATE picture pc
#     JOIN pic_time pt ON pc.id = pt.id
# SET
#     pc.createTime = pt.createTime,
#     pc.editTime = pt.editTime,
#     pc.updateTime = pt.updateTime,
#     pc.reviewTime = pt.reviewTime;

# -- 安全删除旧表（如果存在）
# DROP TABLE IF EXISTS `picture_dns`;
#
# -- 再创建并复制数据
# CREATE TABLE `picture_dns` LIKE `picture`;
# INSERT INTO `picture_dns` SELECT * FROM `picture`;