@isTest
private class PaginatedSelectListTest {
	static testMethod void InsertNewProspectBucket() {
	     
	    List<SelectOption> selectList=new List<SelectOption>();
	    PaginatedSelectList p = new PaginatedSelectList ();
	    for(Integer i=1;i<=20000;i++){
	    	p.add(new SelectOption(i+'',i+''));
	    }
	     p.get(0);
	     p.remove(0);
	     p.clear();
	     p.getSelectList();
	     p.getSubList(1,10);
	     p.getNthSubList(0);
	     p.get0();
	     p.get1();
	     p.get2();
	     p.get3();
	     p.get4();
	     p.get5();
	     p.get6();
	     p.get7();
	     p.get8();
	     p.get9();
	     p.get10();
	     p.get11();
	     p.get12();
	     p.get13();
	     p.get14();
	     p.get15();
	     p.get16();
	     p.get17();
	     p.get18();
	     p.get19();    
    }
}