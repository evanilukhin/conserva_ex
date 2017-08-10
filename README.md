# Conserva

Microservice for parallel convert files by system apps or other services.

## Install
### Manual installation from source
In addition to elixir,  we need to install some other packages: wget, make, curl.
**Install Elixir**
We need Elixir version 1.4.1 or above. Instruction can founded [here](https://elixir-lang.org/install.html).
**Get source files**
Download or clone source files from [github](https://github.com/evanilukhin/conserva) and move to your app directory.
**Get and compile dependensies**
```shell
yes | mix do deps.get, deps.compile
```
In addition to elixir librares, this command install [hex](https://hex.pm/) and [rebar3](https://www.rebar3.org/), if they not installed in system.

## Configure and preparing to launch

### Create database
As database Conserva use Postgres, therefore example below writed on psql.

```postgresql
CREATE DATABASE conserva;
CREATE USER conserva_user WITH password 'strong_password';
GRANT ALL PRIVILEGES ON DATABASE conserva TO conserva_user;
```
If you want use another database, add to `mix.exs` file appropriated adapter:
```elixir
defp deps do
  [{:adapter_name, ">= 0.0.0"},
   {:ecto, "~> 2.1"}]
end
```

List all available adapters see [this](https://github.com/elixir-ecto/ecto#usage).

### Configuration

Copy file config/config.exs.example to config/config.exs and edit it. This config file consist of the three parts:
1. Database connection settings
2. Files settings
3. Logging settings

All parameters have detailed comments, therefore let's not dwell on it.

### Setup converters

In app config file we are setup directory with converters setting files. Converter settings files have extension *.yaml and have next parameters:
- name: image_magic_converter #unique name of converter, must be written in snake case
- max_workers_count: 20 # maximum converters working simultaneously
- from_ext: [jpg, png, gif] # source file formats       
- to_ext: [jpg, png, gif, pdf] # target file formats  
- launch_string: "magick {:full_source_path} {:full_output_path}" # this string run the converter CLI with substituting parameters in curved brackets, to date support next parameters
  - :full_source_path - full path to source file - /mount/dir/source.rar
  - :full_output_path - full path to result file - /mount/dir/result.jpg       
  - :output_dir - directory where are located source and result files - /mount/dir
  - :input_extension - input file extension - rar
  - :output_extension - result file extension - jpg

For example, launch string:
```shell
libreoffice --headless --convert-to {:output_extension} --outdir {:output_dir} {:full_source_path} --invisible
```
, will explained into:
```shell
libreoffice --headless --convert-to pdf --outdir /mounted/dir/with/files /mounted/dir/with/files/source.doc --invisible
```

where `/mounted/dir/with/files` directory are determined in config.exs in `file_storage_path` option.

## Run

```shell
elixir --name  conserva@192.168.75.128 --cookie "SecretApp " -S mix run --no-compile --no-halt
```

## Service commands

### Create API key

Run this command in app directory:
```shell
mix conserva.create_api_key -n "Name" -c "Comment"
```
Command return uuid in last string. Example returned uuid: 'b060ee95-91b4-4c75-bfaa-bda0f7e4c9a8'. This command have optional keys:

* -n - name;
* -c - comment.

This parameters are storing information only for symplify searching. At this moment, registered uuids and they information can be watched only in database in table `api_keys`.

## API
All request requierd existed api_key, otherwise server return 403.
### Ping server
`GET http://<address>/ping?api_key=<api_key>` - command for manual check, live service or not (and existing api_key).

**Results**

| HTTP code   	| Possible  message 	| Description 	|
|-------------	|-------------------	|-------------	|
| 200         	|                   	| Alive!     	|

**Examples**
All right
```shell
curl -v  "http://0.0.0.0:4001/ping?api_key=98ae4687-07e6-4381-87a6-7bbe336abffd"
*   Trying 0.0.0.0...
* Connected to 0.0.0.0 (127.0.0.1) port 4001 (#0)
> GET /ping?api_key=98ae4687-07e6-4381-87a6-7bbe336abffd HTTP/1.1
> Host: 0.0.0.0:4001
> User-Agent: curl/7.47.0
> Accept: */*
>
< HTTP/1.1 200 OK
< server: Cowboy
< date: Thu, 10 Aug 2017 11:43:56 GMT
< content-length: 0
< cache-control: max-age=0, private, must-revalidate
<
* Connection #0 to host 0.0.0.0 left intact

```
### Get available convert combinations
`GET http://<address>/api/v1/convert_combinations?api_key=<api_key>` - get all possible file transformations. Return json-array pairs as - *[source_extension, result_extension]*

**Results**

| HTTP code   	| Possible  message 	| Description 	|
|-------------	|-------------------	|-------------	|
| 200         	| [[pdf, jpg], [jpg, pdf]]   |     	|

**Example**
```shell
curl -v  "http://0.0.0.0:4001/api/v1/convert_combinations?api_key=98ae4687-07e6-4381-87a6-7bbe336abffd"
*   Trying 0.0.0.0...
* Connected to 0.0.0.0 (127.0.0.1) port 4001 (#0)
> GET /api/v1/convert_combinations?api_key=98ae4687-07e6-4381-87a6-7bbe336abffd HTTP/1.1
> Host: 0.0.0.0:4001
> User-Agent: curl/7.47.0
> Accept: */*
>
< HTTP/1.1 200 OK
< server: Cowboy
< date: Thu, 10 Aug 2017 11:49:52 GMT
< content-length: 458
< cache-control: max-age=0, private, must-revalidate
<
* Connection #0 to host 0.0.0.0 left intact
[["doc","pdf"],["doc","doc"],["doc","docx"],["doc","odt"],["docx","pdf"],["docx","doc"],["docx","docx"],["docx","odt"],["txt","pdf"],["txt","doc"],["txt","docx"],["txt","odt"],["xls","pdf"],["xls","doc"],["xls","docx"],["xls","odt"],["odt","pdf"],["odt","doc"],["odt","docx"],["odt","odt"],["jpg","jpg"],["jpg","png"],["jpg","gif"],["jpg","pdf"],["png","jpg"],["png","png"],["png","gif"],["png","pdf"],["gif","jpg"],["gif","png"],["gif","gif"],["gif","pdf"]]
```
### Create task
`POST http://<address>/api/v1/task?api_key=<api_key&input_extension=<input_extension>&output_extension=<output_extension>` - create task from file. File taken from multipart option `file`.

**Result**

| HTTP code   	| Possible  message 	| Description 	|
|-------------	|-------------------	|-------------	|
| 200         	| 42                  	| Return task id, if it successfully created  and added to quiue|
| 422         	|                   	| Failed creating task,  see logs.	|

**Example**

Succesfull creating task
```shell
curl -v -F "file=@very_large_piece_of_sheet.doc" "http://0.0.0.0:4001/api/v1/task?input_extension=doc&output_extension=pdf&api_key=98ae4687-07e6-4381-87a6-7bbe336abffd"
*   Trying 0.0.0.0...
* Connected to 0.0.0.0 (127.0.0.1) port 4001 (#0)
> POST /api/v1/task?input_extension=doc&output_extension=pdf&api_key=98ae4687-07e6-4381-87a6-7bbe336abffd HTTP/1.1
> Host: 0.0.0.0:4001
> User-Agent: curl/7.47.0
> Accept: */*
> Content-Length: 22441693
> Expect: 100-continue
> Content-Type: multipart/form-data; boundary=------------------------f662d4363e2d4c4a
>
< HTTP/1.1 100 Continue
< HTTP/1.1 200 OK
< server: Cowboy
< date: Thu, 10 Aug 2017 12:08:17 GMT
< content-length: 2
< cache-control: max-age=0, private, must-revalidate
<
* Connection #0 to host 0.0.0.0 left intact
64⏎   
```
### Get information about task
`GET http://<address>/api/v1/task/<task_id>?api_key=<api_key>` - return info about task with id `<task_id>`.

Url return JSON-object with next fields:

* id - task id;
* state - one of next states: 'received', 'process', 'finished', 'error';
* source_filename;
* result_filename;
* input_extension;
* output_extension;
* created_at;
* updated_at;
* finished_at;
* errors - JSON-array errors;
* source_file_sha256;
* result_file_sha256.

**Result**

| HTTP code   	| Possible  message 	| Description 	|
|-------------	|-------------------	|-------------	|
| 200         	| {"updated_at":"2017-08-10T12:09:11","state":"finished","source_filename":"very_large_piece_of_sheet.doc","source_file_sha256":"D8EDA01B1A54E828AC9E7E4C4D9315853E7EB51CFDF12D2F5D5D246FA36D4481","result_filename":"very_large_piece_of_sheet.pdf","result_file_sha256":"9446EE44130ED791AAF744157AE735D65F6E9F7E736ECD2C07525F985809160B","output_extension":"pdf","input_extension":"pdf","id":64,"finished_at":"2017-08-10T12:09:11","errors":null,"created_at":"2017-08-10T12:08:17"}	| |
| 404 	|  Task does not exist                 	|  Task does not exist) |

**Example**

```shell
curl -v  "http://0.0.0.0:4001/api/v1/task/64?api_key=98ae4687-07e6-4381-87a6-7bbe336abffd"
*   Trying 0.0.0.0...
* Connected to 0.0.0.0 (127.0.0.1) port 4001 (#0)
> GET /api/v1/task/64?api_key=98ae4687-07e6-4381-87a6-7bbe336abffd HTTP/1.1
> Host: 0.0.0.0:4001
> User-Agent: curl/7.47.0
> Accept: */*
>
< HTTP/1.1 200 OK
< server: Cowboy
< date: Thu, 10 Aug 2017 15:19:40 GMT
< content-length: 473
< cache-control: max-age=0, private, must-revalidate
<
* Connection #0 to host 0.0.0.0 left intact
{"updated_at":"2017-08-10T12:09:11","state":"finished","source_filename":"very_large_piece_of_sheet.doc","source_file_sha256":"D8EDA01B1A54E828AC9E7E4C4D9315853E7EB51CFDF12D2F5D5D246FA36D4481","result_filename":"very_large_piece_of_sheet.pdf","result_file_sha256":"9446EE44130ED791AAF744157AE735D65F6E9F7E736ECD2C07525F985809160B","output_extension":"pdf","input_extension":"pdf","id":64,"finished_at":"2017-08-10T12:09:11","errors":null,"created_at":"2017-08-10T12:08:17"}
```

### Download result
`GET http://<address>/api/v1/task/<id_task>/download?api_key=<api_key>` - download result.

**Result**

| HTTP code   	| Possible  message 	| Description 	|
|-------------	|-------------------	|-------------	|
| 200         	|                   	| And start file downloading |
| 202         	|                   	| Task exist, but processing |
| 404         	|  Task does not exist                 	|  Task does not exist)	|

**Example**
```shell
curl -v  "http://0.0.0.0:4001/api/v1/task/66/download?api_key=98ae4687-07e6-4381-87a6-7bbe336abffd"
*   Trying 0.0.0.0...
* Connected to 0.0.0.0 (127.0.0.1) port 4001 (#0)
> GET /api/v1/task/66/download?api_key=98ae4687-07e6-4381-87a6-7bbe336abffd HTTP/1.1
> Host: 0.0.0.0:4001
> User-Agent: curl/7.47.0
> Accept: */*
>
< HTTP/1.1 200 OK
< server: Cowboy
< date: Thu, 10 Aug 2017 17:01:31 GMT
< content-length: 6270
< cache-control: max-age=0, private, must-revalidate
< Content-Disposition: filename="1502384482842529068_file.pdf"
<
PDF file content
```

### Remove task

`DELETE http://<address>/api/v1/task/<id_task>?api_key=<api_key>` - manual task removing. Delete task in database and remove all bounded files.

**Result**

| HTTP code   	| Possible  message 	| Description 	|
|-------------	|-------------------	|-------------	|
| 200         	|                   	| And start file downloading |
| 404         	|  Task does not exist                 	|  Task does not exist)	|
| 423         	|                	|  Task in process. Please try again later.|

**Example**
```shell
curl -v -X "DELETE" "http://0.0.0.0:4001/api/v1/task/65?api_key=98ae4687-07e6-4381-87a6-7bbe336abffd"
*   Trying 0.0.0.0...
* Connected to 0.0.0.0 (127.0.0.1) port 4001 (#0)
> DELETE /api/v1/task/65?api_key=98ae4687-07e6-4381-87a6-7bbe336abffd HTTP/1.1
> Host: 0.0.0.0:4001
> User-Agent: curl/7.47.0
> Accept: */*
>
< HTTP/1.1 200 OK
< server: Cowboy
< date: Thu, 10 Aug 2017 17:09:11 GMT
< content-length: 0
< cache-control: max-age=0, private, must-revalidate
<
* Connection #0 to host 0.0.0.0 left intact
```
