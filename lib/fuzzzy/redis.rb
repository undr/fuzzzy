require 'inline'
module Fuzzzy
  module Redis
    # Ruby implementation is:
    # def index_key key, key2=nil
    #   key = "#{key}:#key2" if key2
    #   "#{shared_key}:#{index_key}:#{key}"
    # end
    INDEX_KEY = <<-EOC
VALUE 
_index_key(int argc, VALUE *argv, VALUE self) 
{
  VALUE type = rb_funcall(self, rb_intern("index_type"), 0);
  VALUE shared_key = rb_funcall(self, rb_intern("shared_key"), 0);
  char sep[2] = ":";
  VALUE key, key2, result;
  char * buf;
  unsigned long long length;

  if(rb_scan_args(argc, argv, "11", &key, &key2) == 2) {
    key = rb_str_dup(key);
    rb_str_cat(key, sep, 1);
    rb_str_concat(key, rb_funcall(key2, rb_intern("to_s"), 0));
  }

  length = RSTRING_LEN(shared_key) + RSTRING_LEN(type) + RSTRING_LEN(key) + 4;
  buf = malloc(length);
  snprintf(buf, length, "%s:%s:%s", RSTRING_PTR(shared_key), RSTRING_PTR(type), RSTRING_PTR(key));
  result = rb_str_new2(buf);
  free(buf);

  return result;
}
EOC
    
    inline do |builder|
      builder.add_compile_flags('-std=c99')
      builder.c_raw(INDEX_KEY, :method_name => 'index_key', :arity => -1)
    end
    
    def redis
      Fuzzzy.redis
    end

    def shared_key
      context[:shared_key] ||= "fuzzzy:#{index_name}"
    end

    def dictionary_key id
      "#{shared_key}:dictionary:#{id}"
    end
    
    def counter_key
      "fuzzzy:indexes:info"
    end
    
    def self.counter_key
      "fuzzzy:indexes:info"
    end
  end
end
