package com.mangoyoo.yoopicbackend.dto.picture;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

@Data
public class PictureUploadRequest implements Serializable {

    /**
     * 图片 id（用于修改）
     */
    private Long id;

    /**
     * 文件地址
     */
    private String fileUrl;

    private static final long serialVersionUID = 1L;
    /**
     * 图片名称
     */
    private String picName;
    /**
     * 空间 id
     */
    private Long spaceId;
    /**
     * 分类
     */
    private String category;

    /**
     * 标签
     */
    private List<String> tags;
}



