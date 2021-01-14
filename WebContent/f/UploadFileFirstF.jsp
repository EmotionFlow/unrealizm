<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%// 後方互換のためファイルを用意。その打ち消してOK %>
getServletContext().getRequestDispatcher("/api/UploadFileFirstF.jsp").forward(request,response);
