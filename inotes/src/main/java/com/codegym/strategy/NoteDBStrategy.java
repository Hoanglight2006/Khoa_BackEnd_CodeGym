package com.codegym.strategy;

import com.codegym.model.Note;
import com.codegym.model.NoteType;
import com.codegym.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NoteDBStrategy implements NoteStrategy {

    @Override
    public String getStorageName() {
        return "Cơ sở dữ liệu (MySQL)";
    }

    @Override
    public void save(Note note) {
        if (note.getId() > 0) {
            String sql = "UPDATE notes SET title = ?, content = ?, type_id = ? WHERE id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, note.getTitle());
                ps.setString(2, note.getContent());
                if (note.getTypeId() > 0) {
                    ps.setInt(3, note.getTypeId());
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                ps.setInt(4, note.getId());
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else {
            String sql = "INSERT INTO notes (title, content, type_id) VALUES (?, ?, ?)";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, note.getTitle());
                ps.setString(2, note.getContent());
                if (note.getTypeId() > 0) {
                    ps.setInt(3, note.getTypeId());
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        note.setId(rs.getInt(1));
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void delete(int id) {
        String sql = "DELETE FROM notes WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Note> findAll() {
        List<Note> list = new ArrayList<>();
        String sql = "SELECT n.id, n.title, n.content, n.type_id, t.name AS type_name " +
                     "FROM notes n LEFT JOIN note_type t ON n.type_id = t.id " +
                     "ORDER BY n.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Note note = new Note(
                    rs.getInt("id"),
                    rs.getString("title"),
                    rs.getString("content"),
                    rs.getInt("type_id"),
                    rs.getString("type_name")
                );
                list.add(note);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Note findById(int id) {
        String sql = "SELECT n.id, n.title, n.content, n.type_id, t.name AS type_name " +
                     "FROM notes n LEFT JOIN note_type t ON n.type_id = t.id " +
                     "WHERE n.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Note(
                        rs.getInt("id"),
                        rs.getString("title"),
                        rs.getString("content"),
                        rs.getInt("type_id"),
                        rs.getString("type_name")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Note> search(String keyword) {
        List<Note> list = new ArrayList<>();
        String sql = "SELECT n.id, n.title, n.content, n.type_id, t.name AS type_name " +
                     "FROM notes n LEFT JOIN note_type t ON n.type_id = t.id " +
                     "WHERE n.title LIKE ? OR n.content LIKE ? " +
                     "ORDER BY n.id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String query = "%" + (keyword != null ? keyword.trim() : "") + "%";
            ps.setString(1, query);
            ps.setString(2, query);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Note note = new Note(
                        rs.getInt("id"),
                        rs.getString("title"),
                        rs.getString("content"),
                        rs.getInt("type_id"),
                        rs.getString("type_name")
                    );
                    list.add(note);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<NoteType> findAllTypes() {
        List<NoteType> types = new ArrayList<>();
        String sql = "SELECT id, name, description FROM note_type ORDER BY id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                types.add(new NoteType(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("description")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Nếu database chưa có dữ liệu note_type thì cung cấp các thể loại mặc định
        if (types.isEmpty()) {
            types.add(new NoteType(1, "Cá nhân", "Ghi chú việc riêng"));
            types.add(new NoteType(2, "Công việc", "Công việc văn phòng, nhiệm vụ"));
            types.add(new NoteType(3, "Học tập", "Kiến thức và bài tập ôn tập"));
        }
        return types;
    }
}
