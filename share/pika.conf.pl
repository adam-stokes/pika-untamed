{   connection => [
        {   network => {
                canonical => {
                    server   => 'irc.freenode.net',
                    port     => 6667,
                    username => 'pika',
                    nickname => 'pika',
                    realname => 'PIKAPIKA',
                    plugins  => [qw(join)]
                }
            }
        }
    ],
    plugins => {
        join    => {channels => ['#pika-test', '#pika-test2']},
    }
};

