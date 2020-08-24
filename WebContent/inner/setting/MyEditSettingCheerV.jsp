<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="SettingList">
    <div class="SettingListItem">
        <div class="SettingListTitle">現在のポチ袋ポイント</div>
        <div class="SettingBody">
            <p style="text-align: center; font-size: 17px; margin-bottom: 8px;">
                <%=String.format("%,d",cResults.m_nCheerPoint)%>ポイント
            </p>
        </div>
        <div class="SettingListTitle">今後の予定</div>
        <p>
            ファンのみなさまから送られたポチ袋は、運営にて取りまとめたのち、
            クリエイターのみなさまにポチ袋ポイントとして還元されます。
        </p>
        <p>
            ポチ袋ポイントは、９月頃から１ポチ袋ポイント＝１円で、
            あらかじめ登録いただいた口座に振込みできるよう、準備を進めています。
        </p>
    </div>
</div>
