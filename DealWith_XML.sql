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

