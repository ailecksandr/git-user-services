ROOT_PATH = File.dirname(__FILE__)

require File.join(ROOT_PATH, 'lib/loader')

Lib::Loader.(ROOT_PATH)
