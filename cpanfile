requires 'perl', '5.008001';

requires 'Cache::FastMmap';
requires 'Config::Pit';
requires 'HTTP::Request::Common';
requires 'IPC::Open2';
requires 'JSON';
requires 'LWP::UserAgent';
requires 'Log::Minimal';
requires 'Mouse';
requires 'Try::Tiny';
requires 'String::CamelCase';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
