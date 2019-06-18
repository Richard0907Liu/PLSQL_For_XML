-- 1a) 

create table BN_XML (
    BNDATA sys.xmltype
)
/

-- 1b) for BN_XML
declare
    attr1 varchar(20); attr2 varchar(10); attr3 varchar(10);
    attr4 varchar(10); attr5 varchar(400);
    cursor test is select * from neigh;
begin
    open test;
    loop
        fetch test into attr1, attr2, attr3, attr4, attr5;
        if test%found
        then      
                attr1 := substr(attr1, 0, instr(attr1, 'CB')-2);
                split_neighborhoods_for_XML(attr1, attr5);
        else 
            exit;
        end if;
    end loop;
    close test;
end;
/
-- create a procedure to process column
create or replace procedure split_neighborhoods_for_XML(CB in varchar2, neighborhoods in varchar2)
as 
    pre_split varchar2(400);
    single_neigh varchar2(60);
    from_ number;
    comma_site number;
    len number;
    
    XML_content varchar2(200);
begin
    len := length(neighborhoods);
    --dbms_output.put_line('String showed in the procedure split_neighborhoods, number of words: ' || len );
    --dbms_output.put_line(neighborhoods);           
    from_ := 0;
    pre_split := neighborhoods;
    loop
        pre_split := substr(pre_split, from_, len);
        comma_site := instr(pre_split, ',');
        if comma_site =0
        then 
            single_neigh := substr(pre_split,0, length(pre_split));

            XML_content := '<BN>' || '<BORO>' || CB || '</BORO>' || 
                            '<NEIGH>' || single_neigh || '</NEIGH>' || '</BN>';
            dbms_output.put_line(XML_content); 
            
            insert into BN_XML values(
                sys.XMLType.createXML(XML_content)
            );
            
            exit;
        else
            single_neigh := substr(pre_split, 0, comma_site-1);

            XML_content := '<BN>' || '<BORO>' || CB || '</BORO>' || 
                                '<NEIGH>' || single_neigh || '</NEIGH>' || '</BN>';
            
            dbms_output.put_line(XML_content); 
            
            insert into BN_XML values(
                sys.XMLType.createXML(XML_content)
            );                    
                                
        end if;
        from_ := comma_site+2;
        
    end loop;
end;
/

-- 1c)
select a.BNDATA.extract('/').getstringval()as boro_neigh
from BN_XML a
/

-- 1d)
select a.BNDATA.extract('/BN/NEIGH/text()').getstringval()AS NEIGHBORHOODS
from BN_XML a 
where a.BNDATA.existsNode('/BN') = 1
/

-- 3a) 
create table BN_JSON (
    JSONDATA CLOB,
    constraint c2 check (JSONDATA is JSON)  -- constrain "c2" need to be changed for different json tables
)
/

--3b)  For BN_JSON
declare
    attr1 varchar(20); attr2 varchar(10); attr3 varchar(10);
    attr4 varchar(10); attr5 varchar(400);
    cursor test is select * from neigh;
begin
    open test;
    loop
        fetch test into attr1, attr2, attr3, attr4, attr5;
        if test%found
        then      
                attr1 := substr(attr1, 0, instr(attr1, 'CB')-2);
                split_neighborhoods_for_JSON(attr1, attr5);
        else 
            exit;
        end if;
    end loop;
    close test;
end;
/
-- create a procedure to process column
create or replace procedure split_neighborhoods_for_JSON(CB in varchar2, neighborhoods in varchar2)
as 
    pre_split varchar2(400);
    single_neigh varchar2(60);
    from_ number;
    comma_site number;
    len number;
    
    Json_content varchar2(200);
begin
    len := length(neighborhoods);
    --dbms_output.put_line('String showed in the procedure split_neighborhoods, number of words: ' || len );
    --dbms_output.put_line(neighborhoods);           
    from_ := 0;
    pre_split := neighborhoods;
    loop
        pre_split := substr(pre_split, from_, len);
        comma_site := instr(pre_split, ',');
        if comma_site =0
        then 
            single_neigh := substr(pre_split,0, length(pre_split));

            Json_content := '{ "Boro" : ' || '"' || CB || '",' || chr(10) ||    -- char(10), go to next line
                            '  "Neigh" : ' || '"' || single_neigh || '" }';
            dbms_output.put_line(Json_content); 
            
            insert into BN_JSON values(
                Json_content );
            
            exit;
        else
            single_neigh := substr(pre_split, 0, comma_site-1);

            Json_content := '{ "Boro" : ' || '"' || CB || '",' || chr(10) ||    -- char(10), go to next line
                            '  "Neigh" : ' || '"' || single_neigh || '" }';
            dbms_output.put_line(Json_content); 
            
            insert into BN_JSON values(
                Json_content );                   
                                
        end if;
        from_ := comma_site+2;
        
    end loop;
end;
/

-- 3c)
select * from BN_JSON
/



-- 4a)
drop table BNDATA
/

create table BNDATA(
    BNDATA            sys.xmltype
)
/

insert into BNDATA values(
    sys.XMLType.createXML( 
        '<BN>
            <BORO> Staten Island CB 3</BORO>
            <NEIGH>Annadale</NEIGH>
            <NEIGH>Arden Heights</NEIGH>
            <NEIGH>Bay Terrace</NEIGH>
            <NEIGH>Charleston</NEIGH>
            <NEIGH>Eltingville</NEIGH>
            <NEIGH>Great Kills</NEIGH>
            <NEIGH>Greenridge</NEIGH>
            <NEIGH>Huguenot</NEIGH>
            <NEIGH>Pleasant Plains</NEIGH>
            <NEIGH>Prince’s Bay</NEIGH>
            <NEIGH>Richmond Valley</NEIGH>
            <NEIGH>Rossville</NEIGH>
            <NEIGH>Tottenville</NEIGH>
            <NEIGH>Woodrow</NEIGH>
        </BN>')
)
/

select * from BNDATA
/

-- 4b) 
/*Create a table like the example above that represents all Staten Island CB 3 neighborhoods
in JSON by hand. In other words, this would be a table with one single table row. But that table 
row would contain more than 2 text lines. (It is MORE than 2 text lines, because the long […]
will probably overflow and make 3 rows). */

-- 4b)
create table Staten_Island_cb_3_JSON ( 
    JSONDATA CLOB,
    constraint c4 check (JSONDATA is JSON)
)
/

insert into  Staten_Island_cb_3_JSON values(
    '{
        "Boro": "Staten Island CB 3",
        "Neigh": ["Annadale", "Arden Heights", " Bay Terrace", "Charleston", "Eltingville",
                  "Great Kill", "Greenridge", "Huguenot", "Pleasant Plains", "Prince’s Bay",
                  "Richmond Valley", "Rossville", "Tottenville", "Woodrow"
                  ]
    }')
/

select * from Staten_Island_cb_3_JSON
/





create index forgender on PEOPLE(GENDER)
/

Bad design with index.

     SELECT *
     FROM   (
            SELECT /* INDEX( PEOPLE, FORGENDER ) */ *
            FROM   PEOPLE
            WHERE  GENDER = 'M'
            )
     WHERE  AGE = 34
/



drop index forgender
/












