package com.codegym.service;

import com.codegym.model.Note;
import com.codegym.model.NoteType;
import com.codegym.strategy.NoteDBStrategy;
import com.codegym.strategy.NoteFileStrategy;
import com.codegym.strategy.NoteStrategy;

import java.util.List;

public class NoteManagement {
    private static NoteManagement instance;
    private NoteStrategy strategy;

    private NoteManagement() {
        // Mặc định khởi tạo chiến lược Cơ sở dữ liệu (MySQL)
        this.strategy = new NoteDBStrategy();
    }

    public static synchronized NoteManagement getInstance() {
        if (instance == null) {
            instance = new NoteManagement();
        }
        return instance;
    }

    public void setStrategy(NoteStrategy strategy) {
        this.strategy = strategy;
    }

    public NoteStrategy getStrategy() {
        return strategy;
    }

    // Chuyển đổi chiến lược lưu trữ động (Runtime Pluggable Storage)
    public void switchStorage(String mode) {
        if ("file".equalsIgnoreCase(mode)) {
            if (!(this.strategy instanceof NoteFileStrategy)) {
                this.strategy = new NoteFileStrategy();
            }
        } else {
            if (!(this.strategy instanceof NoteDBStrategy)) {
                this.strategy = new NoteDBStrategy();
            }
        }
    }

    public List<Note> searchNotes(String keyword) {
        return strategy.search(keyword);
    }

    public void addNote(String title, String content, int typeId) {
        Note note = new Note(title, content, typeId);
        strategy.save(note);
    }

    public void updateNote(int id, String title, String content, int typeId) {
        Note note = new Note(id, title, content, typeId);
        strategy.save(note);
    }

    public void deleteNote(int id) {
        strategy.delete(id);
    }

    public void saveNote(Note note) {
        strategy.save(note);
    }

    public List<Note> getAllNotes() {
        return strategy.findAll();
    }

    public Note getNoteById(int id) {
        return strategy.findById(id);
    }

    public List<NoteType> getAllTypes() {
        return strategy.findAllTypes();
    }
}
