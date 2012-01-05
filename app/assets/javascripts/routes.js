(function(){

  var defaults = {
    prefix: '',
    format: ''
  };
  
  var Utils = {

    serialize: function(obj){
      if (obj === null) {return '';}
      var s = [];
      for (prop in obj){
        if (obj[prop]) {
          s.push(prop + "=" + encodeURIComponent(obj[prop].toString()));
        }
      }
      if (s.length === 0) {
        return '';
      }
      return "?" + s.join('&');
    },

    clean_path: function(path) {
      return path.replace(/\/+/g, "/").replace(/[\)\(]/g, "").replace(/\.$/m, '').replace(/\/$/m, '');
    },

    extract: function(name, options) {
      var o = undefined;
      if (options.hasOwnProperty(name)) {
        o = options[name];
        delete options[name];
      } else if (defaults.hasOwnProperty(name)) {
        o = defaults[name];
      }
      return o;
    },

    extract_format: function(options) {
      var format = options.hasOwnProperty("format") ? options.format : defaults.format;
      delete options.format;
      return format ? "." + format : "";
    },

    extract_anchor: function(options) {
      var anchor = options.hasOwnProperty("anchor") ? options.anchor : null;
      delete options.anchor;
      return anchor ? "#" + anchor : "";
    },

    extract_options: function(number_of_params, args) {
      if (args.length > number_of_params) {
        return typeof(args[args.length-1]) == "object" ?  args.pop() : {};
      } else {
        return {};
      }
    },

    path_identifier: function(object) {
      if (!object) {
        return "";
      }
      if (typeof(object) == "object") {
        return (object.to_param || object.id || object).toString();
      } else {
        return object.toString();
      }
    },

    build_path: function(number_of_params, parts, optional_params, args) {
      args = Array.prototype.slice.call(args);
      var result = Utils.get_prefix();
      var opts = Utils.extract_options(number_of_params, args);
      if (args.length > number_of_params) {
        throw new Error("Too many parameters provided for path");
      }
      var params_count = 0, optional_params_count = 0;
      for (var i=0; i < parts.length; i++) {
        var part = parts[i];
        if (Utils.optional_part(part)) {
          var name = optional_params[optional_params_count];
          optional_params_count++;
          // try and find the option in opts
          var optional = Utils.extract(name, opts);
          if (Utils.specified(optional)) {
            result += part;
            result += Utils.path_identifier(optional);
          }
        } else {
          result += part;
          if (params_count < number_of_params) {
            params_count++;
            var value = args.shift();
            if (Utils.specified(value)) {
              result += Utils.path_identifier(value);
            } else {
              throw new Error("Insufficient parameters to build path");
            }
          }
        }
      }
      var format = Utils.extract_format(opts);
      var anchor = Utils.extract_anchor(opts);
      return Utils.clean_path(result + format + anchor) + Utils.serialize(opts);
    },

    specified: function(value) {
      return !(value === undefined || value === null);
    },

    optional_part: function(part) {
      return part.match(/\(/);
    },

    get_prefix: function(){
      var prefix = defaults.prefix;

      if( prefix !== "" ){
        prefix = prefix.match('\/$') ? prefix : ( prefix + '/');
      }
      
      return prefix;
    }

  };

  window.Routes = {
// get_events_events => /events/get_events(.:format)
  get_events_events_path: function(options) {
  return Utils.build_path(0, ["/events/get_events"], ["format"], arguments)
  },
// move_events => /events/move(.:format)
  move_events_path: function(options) {
  return Utils.build_path(0, ["/events/move"], ["format"], arguments)
  },
// resize_events => /events/resize(.:format)
  resize_events_path: function(options) {
  return Utils.build_path(0, ["/events/resize"], ["format"], arguments)
  },
// events => /events(.:format)
  events_path: function(options) {
  return Utils.build_path(0, ["/events"], ["format"], arguments)
  },
// new_event => /events/new(.:format)
  new_event_path: function(options) {
  return Utils.build_path(0, ["/events/new"], ["format"], arguments)
  },
// edit_event => /events/:id/edit(.:format)
  edit_event_path: function(_id, options) {
  return Utils.build_path(1, ["/events/", "/edit"], ["format"], arguments)
  },
// event => /events/:id(.:format)
  event_path: function(_id, options) {
  return Utils.build_path(1, ["/events/"], ["format"], arguments)
  },
// microposts => /microposts(.:format)
  microposts_path: function(options) {
  return Utils.build_path(0, ["/microposts"], ["format"], arguments)
  },
// micropost => /microposts/:id(.:format)
  micropost_path: function(_id, options) {
  return Utils.build_path(1, ["/microposts/"], ["format"], arguments)
  },
// relationships => /relationships(.:format)
  relationships_path: function(options) {
  return Utils.build_path(0, ["/relationships"], ["format"], arguments)
  },
// relationship => /relationships/:id(.:format)
  relationship_path: function(_id, options) {
  return Utils.build_path(1, ["/relationships/"], ["format"], arguments)
  },
// password_sessions => /sessions/password(.:format)
  password_sessions_path: function(options) {
  return Utils.build_path(0, ["/sessions/password"], ["format"], arguments)
  },
// token_sessions => /sessions/token(.:format)
  token_sessions_path: function(options) {
  return Utils.build_path(0, ["/sessions/token"], ["format"], arguments)
  },
// send_password_request_sessions => /sessions/send_password_request(.:format)
  send_password_request_sessions_path: function(options) {
  return Utils.build_path(0, ["/sessions/send_password_request"], ["format"], arguments)
  },
// create_with_token_sessions => /sessions/create_with_token(.:format)
  create_with_token_sessions_path: function(options) {
  return Utils.build_path(0, ["/sessions/create_with_token"], ["format"], arguments)
  },
// sessions => /sessions(.:format)
  sessions_path: function(options) {
  return Utils.build_path(0, ["/sessions"], ["format"], arguments)
  },
// new_session => /sessions/new(.:format)
  new_session_path: function(options) {
  return Utils.build_path(0, ["/sessions/new"], ["format"], arguments)
  },
// session => /sessions/:id(.:format)
  session_path: function(_id, options) {
  return Utils.build_path(1, ["/sessions/"], ["format"], arguments)
  },
// following_user => /users/:id/following(.:format)
  following_user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/", "/following"], ["format"], arguments)
  },
// followers_user => /users/:id/followers(.:format)
  followers_user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/", "/followers"], ["format"], arguments)
  },
// users => /users(.:format)
  users_path: function(options) {
  return Utils.build_path(0, ["/users"], ["format"], arguments)
  },
// new_user => /users/new(.:format)
  new_user_path: function(options) {
  return Utils.build_path(0, ["/users/new"], ["format"], arguments)
  },
// edit_user => /users/:id/edit(.:format)
  edit_user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/", "/edit"], ["format"], arguments)
  },
// user => /users/:id(.:format)
  user_path: function(_id, options) {
  return Utils.build_path(1, ["/users/"], ["format"], arguments)
  },
// users_new => /users/new(.:format)
  users_new_path: function(options) {
  return Utils.build_path(0, ["/users/new"], ["format"], arguments)
  },
// pages_home => /pages/home(.:format)
  pages_home_path: function(options) {
  return Utils.build_path(0, ["/pages/home"], ["format"], arguments)
  },
// pages_contact => /pages/contact(.:format)
  pages_contact_path: function(options) {
  return Utils.build_path(0, ["/pages/contact"], ["format"], arguments)
  },
// pages_about => /pages/about(.:format)
  pages_about_path: function(options) {
  return Utils.build_path(0, ["/pages/about"], ["format"], arguments)
  },
// signout => /signout(.:format)
  signout_path: function(options) {
  return Utils.build_path(0, ["/signout"], ["format"], arguments)
  },
// signin => /signin(.:format)
  signin_path: function(options) {
  return Utils.build_path(0, ["/signin"], ["format"], arguments)
  },
// signup => /signup(.:format)
  signup_path: function(options) {
  return Utils.build_path(0, ["/signup"], ["format"], arguments)
  },
// contact => /contact(.:format)
  contact_path: function(options) {
  return Utils.build_path(0, ["/contact"], ["format"], arguments)
  },
// about => /about(.:format)
  about_path: function(options) {
  return Utils.build_path(0, ["/about"], ["format"], arguments)
  },
// help => /help(.:format)
  help_path: function(options) {
  return Utils.build_path(0, ["/help"], ["format"], arguments)
  },
// root => /
  root_path: function(options) {
  return Utils.build_path(0, ["/"], [], arguments)
  }}
;
  window.Routes.options = defaults;
})();
