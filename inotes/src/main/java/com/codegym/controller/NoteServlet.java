package com.codegym.controller;

import com.codegym.model.Note;
import com.codegym.model.NoteType;
import com.codegym.service.NoteManagement;
import com.codegym.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "NoteServlet", urlPatterns = {"/notes", ""})
public class NoteServlet extends HttpServlet {
    private NoteManagement noteManagement;

    @Override
    public void init() throws ServletException {
        super.init();
        noteManagement = NoteManagement.getInstance();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "new":
                showNewForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "view":
                showView(request, response);
                break;
            case "delete":
                deleteNote(request, response);
                break;
            case "switch-storage":
                switchStorage(request, response);
                break;
            case "list":
            default:
                listNotes(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "create":
                createNote(request, response);
                break;
            case "update":
                updateNote(request, response);
                break;
            case "switch-storage":
                switchStorage(request, response);
                break;
            default:
                listNotes(request, response);
                break;
        }
    }

    private void listNotes(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        List<Note> notes;
        if (keyword != null && !keyword.trim().isEmpty()) {
            notes = noteManagement.searchNotes(keyword.trim());
        } else {
            notes = noteManagement.getAllNotes();
        }

        List<NoteType> types = noteManagement.getAllTypes();
        String currentStorage = noteManagement.getStrategy().getStorageName();
        boolean isDbConnected = DBConnection.isConnected();

        request.setAttribute("notes", notes);
        request.setAttribute("types", types);
        request.setAttribute("keyword", keyword);
        request.setAttribute("currentStorage", currentStorage);
        request.setAttribute("isDbConnected", isDbConnected);
        request.getRequestDispatcher("/views/note-list.jsp").forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<NoteType> types = noteManagement.getAllTypes();
        String currentStorage = noteManagement.getStrategy().getStorageName();

        request.setAttribute("types", types);
        request.setAttribute("currentStorage", currentStorage);
        request.getRequestDispatcher("/views/note-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Note note = noteManagement.getNoteById(id);
            if (note == null) {
                response.sendRedirect(request.getContextPath() + "/notes?error=not_found");
                return;
            }
            List<NoteType> types = noteManagement.getAllTypes();
            String currentStorage = noteManagement.getStrategy().getStorageName();

            request.setAttribute("note", note);
            request.setAttribute("types", types);
            request.setAttribute("currentStorage", currentStorage);
            request.getRequestDispatcher("/views/note-form.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/notes?error=invalid_id");
        }
    }

    private void showView(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Note note = noteManagement.getNoteById(id);
            if (note == null) {
                response.sendRedirect(request.getContextPath() + "/notes?error=not_found");
                return;
            }
            String currentStorage = noteManagement.getStrategy().getStorageName();
            request.setAttribute("note", note);
            request.setAttribute("currentStorage", currentStorage);
            request.getRequestDispatcher("/views/note-view.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/notes?error=invalid_id");
        }
    }

    private void createNote(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        int typeId = 1;
        try {
            typeId = Integer.parseInt(request.getParameter("typeId"));
        } catch (NumberFormatException ignored) {
        }

        noteManagement.addNote(title, content, typeId);
        response.sendRedirect(request.getContextPath() + "/notes?msg=created");
    }

    private void updateNote(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            int typeId = Integer.parseInt(request.getParameter("typeId"));

            noteManagement.updateNote(id, title, content, typeId);
            response.sendRedirect(request.getContextPath() + "/notes?msg=updated");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/notes?error=invalid_id");
        }
    }

    private void deleteNote(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            noteManagement.deleteNote(id);
            response.sendRedirect(request.getContextPath() + "/notes?msg=deleted");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/notes?error=invalid_id");
        }
    }

    private void switchStorage(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String mode = request.getParameter("mode");
        noteManagement.switchStorage(mode);
        response.sendRedirect(request.getContextPath() + "/notes?msg=storage_switched");
    }
}
