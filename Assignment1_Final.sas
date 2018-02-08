*Data Mining Assignment 1;
*Group 7:Mengqi Li,Shuwei Deng, Leo Liu, Jiwei Zeng;

*2;
PROC IMPORT 
        datafile ='C:\DataMining\Assignment1\offers.csv'
		out=offers
		dbms=csv
		replace;
RUN;

PROC IMPORT 
        datafile ='C:\DataMining\Assignment1\testHistory.csv'
		out=testhistory
		dbms=csv
		replace;
RUN;

PROC IMPORT 
        datafile ='C:\DataMining\Assignment1\trainHistory.csv'
		out=trainhistory
		dbms=csv
		replace;
RUN;

PROC IMPORT 
        datafile ='C:\DataMining\Assignment1\transactions.csv'
		out=transactions
		dbms=csv
		replace;
RUN;

*3;
DATA newtrain;
SET work.trainhistory;
DROP repeattrips;
RUN;

*4;
PROC SQL NOPRINT;
         create table newtrain2 as
		 select * 
		 from newtrain
		 join offers
		 on newtrain.offer=offers.offer;
QUIT;

PROC SQL NOPRINT;
         create table newtest2 as
		 select * 
		 from testhistory
		 join offers
		 on testhistory.offer=offers.offer;
QUIT;

*5;
PROC SQL NOPRINT;
         create table transactions2 as
		 select id,category,MAX(purchasequantity) as max_quantity,MAX(purchaseamount) as max_amount
		 from transactions
		 group by id,category;
QUIT;

DATA newtest3;
     merge newtest2(in=in_left) transactions2;
	 by id category;
	 if max_quantity = . then max_quantity = 0;
	 if max_amount = . then max_amount = 0;
	 if in_left;
RUN;

DATA newtrain3;
     merge newtrain2(in=in_left) transactions2;
	 by id category;
	 if max_quantity = . then max_quantity = 0;
	 if max_amount = . then max_amount = 0;
	 if in_left;
RUN;

*6;

PROC SQL;
ALTER table transactions
ADD record num label='record' format=5.0;
UPDATE transactions SET record=1;
QUIT;

PROC SQL NOPRINT;
         create table tran_train as
		 select distinct newtrain3.*, transactions.record
		 from newtrain3
		 left outer join transactions
		 on newtrain3.id=transactions.id 
         and newtrain3.category=transactions.category
         and newtrain3.company=transactions.company 
         and newtrain3.brand=transactions.brand
         and newtrain3.offerdate > transactions.date;
QUIT;

DATA newtrain4;
     SET tran_train;
	 if record = . then record = 0;
RUN;

PROC SQL NOPRINT;
         create table tran_test as
		 select distinct newtest3.*, transactions.record
		 from newtest3
		 left outer join transactions
		 on newtest3.id=transactions.id 
         and newtest3.category=transactions.category
         and newtest3.company=transactions.company 
         and newtest3.brand=transactions.brand
         and newtest3.offerdate > transactions.date;
QUIT;

DATA newtest4;
     SET tran_test;
	 if record = . then record = 0;
RUN;

*7;
DATA finaltrain;
SET newtrain4;
if id<14000000 then output finaltrain;
RUN;

PROC EXPORT
      data=finaltrain
	  outfile='C:\DataMining\Assignment1\finaltrain.csv'
      dbms=csv
	  replace;
RUN;

DATA finaltest;
SET newtest4;
if id>4810000000 then output finaltest;
RUN;

PROC EXPORT
      data=finaltest
	  outfile='C:\DataMining\Assignment1\finaltest.csv'
      dbms=csv
	  replace;
RUN;
