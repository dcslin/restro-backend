package restoBackend;
use Dancer2;
use Dancer2::Plugin::Database;
use Data::Dumper;
set serializer => 'JSON';

my $terminals;

our $VERSION = '0.1';

hook 'before' => sub {
    header 'Access-Control-Allow-Origin' => '*';
};

get '/terminal/:id' => sub {
    return _get_terminal_hashref_by_term_id(route_parameters->get('id'));
};


get '/terminals' => sub {
    my $dbh = database('restro');
    my $sql = "select * from terminals";
    my $rows = $dbh->selectall_arrayref($sql, {Slice => {} });

    foreach my $terminal ( @{ $rows } ) {
        #my $inventory = _get_trx_aryref_by_term_id( $terminal->{id} );
        #$terminal->{inventory} = $inventory;

        $terminal = _geoloc_modifier($terminal);
    }

    return $rows;
};

post '/terminal/:id/deposit' => sub {
    my $id           = route_parameters->get('id');
    my $deposits      = request->data;

    info Dumper $deposits;
    my $sql = "insert into transactions ( prediction, confirmed, terminal_id, image ) values";
    foreach my $deposit ( @{ $deposits } ) {
            my $pre = $deposit->{prediction};

            my $confirm = 'false';
            $confirm = 'true' if $deposit->{confirmed};


            my $img = $deposit->{image};
            $sql .= "('$pre', $confirm, $id, '$img'),";
    }

    $sql =~ s/,$//;

    my $dbh = database('restro');

    info Dumper $sql;

    $dbh->do($sql) or return {error_code => 1};



    return {error_code => 0};
};

#========================================================

get '/transaction/:id' => sub {
    return _get_trx_hashref_by_id(route_parameters->get('id'));
};

get '/transactions/terminal/:terminal_id' => sub {
    return _get_trx_aryref_by_term_id(route_parameters->get('terminal_id'));
};



sub _get_terminal_hashref_by_term_id{

    my $inventory = _get_trx_aryref_by_term_id(route_parameters->get('id'));

    my $dbh = database('restro');
    my $sql = "select * from terminals where id = ".route_parameters->get('id');
    my $rows = $dbh->selectall_arrayref($sql, {Slice => {} });

    my $terminal = $$rows[0];
    $terminal->{inventory} = $inventory;


    $terminal = _geoloc_modifier($terminal);

    return $terminal;

}

sub _geoloc_modifier{

    my $terminal = shift;
    $terminal->{geoloc}->{lng} = $terminal->{lng}+0;
    $terminal->{geoloc}->{lat} = $terminal->{lat}+0;
    delete $terminal->{lng};
    delete $terminal->{lat};
    return $terminal;
}

sub _get_trx_hashref_by_id {
    my $id = shift;
    my $dbh = database('restro');
    my $row = $dbh->selectall_arrayref("select * from transactions where id=$id", { Slice => {} });
    return $$row[0];
}

sub _get_trx_aryref_by_term_id {
    my $id = shift;
    my $dbh = database('restro');
    my $row = $dbh->selectall_arrayref("select * from transactions where terminal_id=$id", { Slice => {} });
    info Dumper $row;
    return $row;
}



true;
