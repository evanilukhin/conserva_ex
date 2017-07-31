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
