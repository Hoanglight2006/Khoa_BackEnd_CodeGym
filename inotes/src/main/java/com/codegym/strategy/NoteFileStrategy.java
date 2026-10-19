package com.codegym.strategy;

import com.codegym.model.Note;
import com.codegym.model.NoteType;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class NoteFileStrategy implements NoteStrategy {
    private static final String DEFAULT_FILE_NAME = "notes_data.txt";
    private File file;

    public NoteFileStrategy() {
        // Ưu tiên lưu trong thư mục làm việc của ứng dụng
        this.file = new File(DEFAULT_FILE_NAME);
        ensureFileExists();
    }

    public NoteFileStrategy(String customFilePath) {
        this.file = new File(customFilePath);
        ensureFileExists();
    }

    private void ensureFileExists() {
        try {
            if (!file.exists()) {
                File parent = file.getParentFile();
                if (parent != null && !parent.exists()) {
                    parent.mkdirs();
                }
                file.createNewFile();
                // Khởi tạo dữ liệu mẫu ban đầu
                List<Note> initialNotes = new ArrayList<>();
                initialNotes.add(new Note(1, "Họp giao ban đầu tuần", "Thảo luận tiến độ dự án quý 2 và phân công công việc cụ thể cho từng thành viên trong nhóm.", 2));
                initialNotes.add(new Note(2, "Ôn tập Design Pattern Servlet", "Xem lại cấu trúc MVC, Strategy Pattern và cách triển khai HttpServletRequest/HttpServletResponse trong Jakarta EE.", 3));
                initialNotes.add(new Note(3, "Kế hoạch tập gym", "Lịch tập 4 buổi/tuần: Ngực - Tay sau, Lưng - Tay trước, Chân - Bụng, Nghỉ ngơi cuối tuần.", 1));
                writeNotesToFile(initialNotes);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public String getStorageName() {
        return "Tập tin (File txt/csv)";
    }

    private synchronized List<Note> readNotesFromFile() {
        List<Note> list = new ArrayList<>();
        if (!file.exists()) {
            return list;
        }

        Map<Integer, String> typeMap = getTypeMap();

        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(file), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) {
                    continue;
                }
                // Định dạng phân tách: id|title|content|typeId
                String[] parts = line.split("\\|", -1);
                if (parts.length >= 4) {
                    try {
                        int id = Integer.parseInt(parts[0].trim());
                        String title = unescapeData(parts[1]);
                        String content = unescapeData(parts[2]);
                        int typeId = Integer.parseInt(parts[3].trim());
                        String typeName = typeMap.getOrDefault(typeId, "Khác");

                        list.add(new Note(id, title, content, typeId, typeName));
                    } catch (NumberFormatException ignored) {
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return list;
    }

    private synchronized void writeNotesToFile(List<Note> notes) {
        try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file, false), StandardCharsets.UTF_8))) {
            for (Note note : notes) {
                // Định dạng: id|title|content|typeId
                String line = note.getId() + "|"
                        + escapeData(note.getTitle()) + "|"
                        + escapeData(note.getContent()) + "|"
                        + note.getTypeId();
                bw.write(line);
                bw.newLine();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private String escapeData(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("|", "&#124;")
                    .replace("\r", "")
                    .replace("\n", "\\n");
    }

    private String unescapeData(String input) {
        if (input == null) return "";
        return input.replace("\\n", "\n")
                    .replace("&#124;", "|")
                    .replace("\\\\", "\\");
    }

    private Map<Integer, String> getTypeMap() {
        Map<Integer, String> map = new HashMap<>();
        for (NoteType type : findAllTypes()) {
            map.put(type.getId(), type.getName());
        }
        return map;
    }

    @Override
    public synchronized void save(Note note) {
        List<Note> notes = readNotesFromFile();
        if (note.getId() > 0) {
            // Cập nhật bản ghi có sẵn
            boolean found = false;
            for (int i = 0; i < notes.size(); i++) {
                if (notes.get(i).getId() == note.getId()) {
                    notes.set(i, note);
                    found = true;
                    break;
                }
            }
            if (!found) {
                notes.add(note);
            }
        } else {
            // Tạo mới và tự sinh ID
            int maxId = 0;
            for (Note n : notes) {
                if (n.getId() > maxId) {
                    maxId = n.getId();
                }
            }
            note.setId(maxId + 1);
            notes.add(note);
        }
        writeNotesToFile(notes);
    }

    @Override
    public synchronized void delete(int id) {
        List<Note> notes = readNotesFromFile();
        notes.removeIf(note -> note.getId() == id);
        writeNotesToFile(notes);
    }

    @Override
    public List<Note> findAll() {
        List<Note> notes = readNotesFromFile();
        // Sắp xếp ID giảm dần (mới nhất lên trên)
        notes.sort((a, b) -> Integer.compare(b.getId(), a.getId()));
        return notes;
    }

    @Override
    public Note findById(int id) {
        List<Note> notes = readNotesFromFile();
        for (Note note : notes) {
            if (note.getId() == id) {
                return note;
            }
        }
        return null;
    }

    @Override
    public List<Note> search(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return findAll();
        }
        String lowerKeyword = keyword.trim().toLowerCase();
        List<Note> results = new ArrayList<>();
        for (Note note : readNotesFromFile()) {
            boolean matchTitle = note.getTitle() != null && note.getTitle().toLowerCase().contains(lowerKeyword);
            boolean matchContent = note.getContent() != null && note.getContent().toLowerCase().contains(lowerKeyword);
            if (matchTitle || matchContent) {
                results.add(note);
            }
        }
        results.sort((a, b) -> Integer.compare(b.getId(), a.getId()));
        return results;
    }

    @Override
    public List<NoteType> findAllTypes() {
        List<NoteType> types = new ArrayList<>();
        types.add(new NoteType(1, "Cá nhân", "Ghi chú cho các kế hoạch và việc riêng"));
        types.add(new NoteType(2, "Công việc", "Nhiệm vụ và lịch họp công việc"));
        types.add(new NoteType(3, "Học tập", "Tài liệu và bài tập ôn tập chuyên môn"));
        return types;
    }
}
