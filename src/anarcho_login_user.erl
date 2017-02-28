-module(anarcho_login_user).

-export([login_user/2]).

login_user(<<"mikey">>, <<"atmosia">>) -> {ok, <<"sample token">>};
login_user(<<"mikey">>, _Password)     -> {error, invalid_password};
login_user(_User,       _Password)     -> {error, no_user}.
