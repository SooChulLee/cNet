<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	if(!Site.isPmss(out,"menu_perm","")) return;

	Db db = null;

	try {
		db = new Db(true);

		// user_level list
		String _parent_code = "USER_LEVEL";

		List<Map<String, Object>> user_level_list = db.selectList("code.selectCodeList", _parent_code);
		String col_user_level = "";

		if(user_level_list.size()>0) {
			for(Map<String, Object> item : user_level_list) {
				col_user_level += ",{'" + item.get("comm_code") + "':'" + item.get("code_name") + "'}";
			}
			col_user_level = col_user_level.substring(1);
		}
%>
<jsp:include page="/include/top.jsp" flush="false"/>
<script type="text/javascript">
$(function () {
	var colModel = [
		{ title: "필드명", width: 200, dataIndx: "conf_name",
			validations: [
				{ type: "minLen", value: "1", msg: "필수입력 사항입니다." },
			],
		},
		{ title: "등급", width: 150, dataIndx: "user_level",
			editor: {
				type: 'select',
				options: [<%=col_user_level%>]
			},
			render: function(ui) {

				var options = ui.column.editor.options,
					cellData = ui.cellData;
				for (var i = 0; i < options.length; i++) {
					var option = options[i];
					if (option[cellData]) {
						return option[cellData];
					}
				}

			},
		},
		{ title: "노출순서", dataIndx: "order_no", hidden: true	},
		{ title: "사용여부", width: 100, dataIndx: "use_yn",
			editor: {
				type: 'select',
				options: fn.usedCode.colModel
			},
			render: function(ui) {

				var options = ui.column.editor.options,
					cellData = ui.cellData;
				for (var i = 0; i < options.length; i++) {
					var option = options[i];
					if (option[cellData]) {
						return option[cellData];
					}
				}

			},
		}
	];

	var baseDataModel = getBaseGridDM("<%=page_id%>");
	var dataModel = $.extend({}, baseDataModel, {
		sorting:"local",
		//sortIndx: "order_no",
		//sortDir: "up",
		recIndx: "row_id"
	});

 	// 페이지 id, 페이징 사용여부, 엑셀다운로드 사용여부, 신규등록 사용여부, 수정 사용여부
	var baseObj = getBaseGridOption("result_perm", "N", "N", "N", "Y");
	var obj = $.extend({}, baseObj, {
		colModel: colModel,
		dataModel: dataModel,
		flexWidth: true,
		numberCell:{resizable:true, title:"#"},
	});

	$grid = $("#grid").pqGrid(obj);
});
</script>

	<!--title 영역 -->
	<div class="row titleBar border-bottom2">
		<div style="float:left;"><h4>접근보안 관리</h4></div>
		<ol class="breadcrumb" style="float:right;">
			 <li><a href="#none"><i class="fa fa-home"></i> 관리</a></li>
			 <li><a href="#none">접근보안 관리</a></li>
			 <li class="active"><strong>리스트 접근권한</strong></li>
		</ol>
	</div>
	<!--title 영역 끝 -->

	<!--wrapper-content영역-->
	<div class="wrapper-content">
		<!--탭 메뉴 영역 -->
		<div class="panel blank-panel conSize">
			<div class="panel-heading">
				<div class="panel-options">
					<ul class="nav nav-tabs">
						<li class=""><a href="menu_perm.jsp">메뉴 접근권한</a></li>
						<li class=""><a href="search_perm.jsp">조회 접근권한</a></li>
						<li class="active"><a href="result_perm.jsp">리스트 접근권한</a></li>
					</ul>
				</div>
			</div>
		</div>
		<!--탭 메뉴 영역 끝 -->

		<!--Data table 영역-->
		<div class="contentArea" style="padding-top: 10px;">
			<!--grid 영역-->
			<div id="grid"></div>
			<!--grid 영역 끝-->
		</div>
		<!--Data table 영역 끝-->
	</div>
	<!--wrapper-content영역 끝-->

<jsp:include page="/include/bottom.jsp"/>
<%
	} catch(Exception e) {
		logger.error(e.getMessage());
	} finally {
		if(db!=null) db.close();
	}
%>
