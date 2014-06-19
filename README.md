# NAME

App::OpenZabbix - Quick opener for Zabbix screen using percol or peco.

# SYNOPSIS

    open_zabbix ( screen | host | maintenance | webcheck ) [--command peco/percol/or etc.]
      (at first, Config::Pit opens $EDITOR. Enter your Zabbix URL, user, password.)

# DESCRIPTION

App::OpenZabbix is a quick opener for Zabbix screen, host, maintenance web interface.

# REQUIREMENTS

percol [https://github.com/mooz/percol](https://github.com/mooz/percol)

peco [https://github.com/lestrrat/peco](https://github.com/lestrrat/peco)

# LICENSE

Copyright (C) FUJIWARA Shunichiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

FUJIWARA Shunichiro <fujiwara.shunichiro@gmail.com>
