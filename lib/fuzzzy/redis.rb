require 'inline'
module Fuzzzy
  module Redis
    INDEX_KEY = <<-EOC
VALUE 
_index_key(int argc, VALUE *argv, VALUE self) 
{
  VALUE type = rb_funcall(self, rb_intern("index_type"), 0);
  VALUE shared_key = rb_funcall(self, rb_intern("shared_key"), 0);
  VALUE key, key2;

  if(rb_scan_args(argc, argv, "11", &key, &key2) == 2) {
    char sep[2] = ":\0";
    key = rb_str_dup(key);
    rb_str_cat(key, sep, 1);
    rb_str_concat(key, rb_funcall(key2, rb_intern("to_s"), 0));
  }

  int length = RSTRING_LEN(shared_key) + RSTRING_LEN(type) + RSTRING_LEN(key) + 4;
  char buf[length];

  snprintf(buf, length, "%s:%s:%s", RSTRING_PTR(shared_key), RSTRING_PTR(type), RSTRING_PTR(key));
  return rb_str_new2(buf);
}
EOC
    
    inline do |builder|
      builder.c_raw(INDEX_KEY, :method_name => 'index_key', :arity => -1)
    end
    
    def redis
      Fuzzzy.redis
    end

    def shared_key
      context[:shared_key] ||= "fuzzzy:#{model_name}:#{context[:field]}"
    end

    def dictionary_key id
      "#{shared_key}:dictionary:#{id}"
    end

    
  end
end
