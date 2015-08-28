package __PACKAGE__ ;

import java.util.Date;
import java.util.GregorianCalendar;

public class __FILE_NAME__ {

    private Date creationDate;

    public __FILE_NAME__() {
	creationDate = (new GregorianCalendar()).getTime();
    }
    
    public void sayHi() {
	System.out.println("Hello Cleveland!");
    }

    public String toString() {
	return "__FILE_NAME__ " + creationDate;
    }
    
}
