sql2dbf
=======
Консольное приложение (Win32), позволяющее экспортировать данные из SQL-сервера в DBF-файл.
В параметрах принимает строку соединения с SQL-сервером, файл с SQL запросом и файл со структурой создаваемого dbf-файла.

Имена полей в DBF-файле и имена полей, возвращаемых SQL-запросом должны совпадать


## Параметры командной строки.
 -srv=Строка соединения с SQL-сервером
 -sql=Текстовый файл с SQL-запросом
 -dbfstr=Текстовый файл со структурой создаваемого DBF-файла
 -dbf=имя создаваемого DBF-файла

### Пример вызова программы.
 sql2dbf -srv="Provider=SQLOLEDB.1;User ID=simpleuser;Password=password;Persist Security Info=False;Initial Catalog=MyDatabase;Data Source=127.0.0.1\mssqlserver1" -sql=get_records.sql -dbfstr=strucure.lst -dbf=newfile.dbf

### Пример файла со структурой. 
SHORTNAME;C;9;0
SALARY;N;6;2
ID;N;6;0
## Сторонние компоненты
Halcyon 6
