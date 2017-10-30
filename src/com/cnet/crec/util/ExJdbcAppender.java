package com.cnet.crec.util;

import java.lang.reflect.Field;

import org.apache.log4j.jdbc.JDBCAppender;
import org.apache.log4j.spi.LoggingEvent;

public class ExJdbcAppender extends JDBCAppender {
	@Override
	protected String getLogStatement(LoggingEvent event) {

		Object eventMsgObj = event.getMessage();

		if( eventMsgObj != null && eventMsgObj.toString() != null ) {
			if( eventMsgObj.toString().contains("'") ) {
				replace(event, "message");
				replace(event, "renderedMessage");
			}
		}

		if (null != event.getThrowableInformation() ) {

			Throwable throwable = event.getThrowableInformation().getThrowable();

			replace(new Throwable().getClass(), throwable, "detailMessage");

			replace(throwable, "message");

			// stack trace를 출력할 때는 rep 멤버변수의 문자열이 출력되서 rep도 '를 ''으로 치환해야 한다.
			replace(event.getThrowableInformation(), "rep");
		}

		// 이 문자열이 올바른 SQL문이 되는지 console로 출력해서 확인해 본다.
		String format = getLayout().format(event);

		//System.out.println("##############################");
		//System.out.println(format);

		return format;
	}

	private void replace(Object object, String field) {
		replace(object.getClass(), object, field);
	}

	// DB에 저장하기 위해서는 (') 를 ('')로 치환해야지 에러없이 제대로 입력된다.
	private void replace(Class<?> clazz, Object object, String field) {
		try {
			Field f = clazz.getDeclaredField(field);
			f.setAccessible(true);
			if( f.get(object) != null ) {
				if( f.get(object) instanceof String[] ) {
					String[] stringArr = (String[]) f.get(object);
					for (int i = 0; i < stringArr.length; i++) {
						stringArr[i] = stringArr[i].replaceAll("'", "''");
					}
				} else {
					String value =  f.get(object).toString();
					if( value.contains("'") ) {
						f.set(object, value.replaceAll("'", "''"));
					}
				}
			}
		} catch (NoSuchFieldException | SecurityException | IllegalArgumentException | IllegalAccessException e) {
			//e.printStackTrace();
		}
	}
}
