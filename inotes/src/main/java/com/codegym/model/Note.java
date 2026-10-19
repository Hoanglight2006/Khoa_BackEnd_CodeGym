package com.codegym.model;

import com.codegym.service.NoteManagement;

public class Note {
    private int id;
    private String title;
    private String content;
    private int typeId;
    private String typeName; // Thuộc tính bổ trợ hiển thị tên thể loại

    public Note() {
    }

    public Note(String title, String content, int typeId) {
        this.title = title;
        this.content = content;
        this.typeId = typeId;
    }

    public Note(int id, String title, String content, int typeId) {
        this.id = id;
        this.title = title;
        this.content = content;
        this.typeId = typeId;
    }

    public Note(int id, String title, String content, int typeId, String typeName) {
        this.id = id;
        this.title = title;
        this.content = content;
        this.typeId = typeId;
        this.typeName = typeName;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getTypeId() {
        return typeId;
    }

    public void setTypeId(int typeId) {
        this.typeId = typeId;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    // Lưu hoặc cập nhật ghi chú vào hệ thống lưu trữ hiện tại
    public void save() {
        NoteManagement.getInstance().saveNote(this);
    }

    // Xóa ghi chú theo ID khỏi hệ thống lưu trữ hiện tại
    public static void delete(int id) {
        NoteManagement.getInstance().deleteNote(id);
    }
}
