package com.mangoyoo.yoopicbackend.manager.websocket.disruptor;

import com.mangoyoo.yoopicbackend.manager.websocket.model.PictureEditRequestMessage;
import com.mangoyoo.yoopicbackend.model.entity.User;
import lombok.Data;
import org.springframework.web.socket.WebSocketSession;

@Data
public class PictureEditEvent {

    /**
     * 消息
     */
    private PictureEditRequestMessage pictureEditRequestMessage;

    /**
     * 当前用户的 session
     */
    private WebSocketSession session;

    /**
     * 当前用户
     */
    private User user;

    /**
     * 图片 id
     */
    private Long pictureId;

}

