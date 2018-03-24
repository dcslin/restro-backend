package restoBackend;
use Dancer2;
use Data::Dumper;
set serializer => 'JSON';

my $terminals;

BEGIN {
    $terminals = _init_term();

    sub _init_term {
        return [
            {
                id        => '1',
                inventory => [
                    { type => 'bulb',           count => '20' },
                    { type => 'battery',        count => '200' },
                    { type => 'plastic-bottle', count => '30' }
                ]
            },
            {
                id        => '2',
                inventory => [
                    { type => 'bulb',           count => '15' },
                    { type => 'battery',        count => '280' },
                    { type => 'plastic-bottle', count => '90' }
                ]
            },
            {
                id        => '3',
                inventory => [
                    { type => 'bulb',           count => '0' },
                    { type => 'battery',        count => '110' },
                    { type => 'plastic-bottle', count => '40' }
                ]
            },
        ];
    }
}

our $VERSION = '0.1';

post '/terminal/:id/deposit' => sub {
    my $id           = route_parameters->get('id');
    my $deposit_unit = request->data;

    my $terminal = _get_terminal_from_terms( route_parameters->get('id') );
    send_error( "Not Found", 404 ) unless $terminal;

    foreach my $increment_unit ( @{$deposit_unit} ) {
        foreach my $inv_unit ( @{ $terminal->{inventory} } ) {

            if ( $inv_unit->{type} eq $increment_unit->{type} ) {
                info "adding amount: [".$increment_unit->{increment}."] to type [".$inv_unit->{type}."]";
                $inv_unit->{count} += $increment_unit->{increment};
                info "new amount: [".$inv_unit->{count}."] for type [".$inv_unit->{type}."]";
            }
        }
    }

    return _get_terminal_from_terms( route_parameters->get('id') );
};

get '/terminal/:id' => sub {
    my $terminal = _get_terminal_from_terms( route_parameters->get('id') );
    send_error( "Not Found", 404 ) unless $terminal;
    return $terminal;

};

get '/terminals' => sub {
    return $terminals;
};

sub _get_terminal_from_terms {
    my $id = shift;
    foreach my $terminal ( @{$terminals} ) {
        if ( $terminal->{id} eq $id ) {
            return $terminal;
        }
    }
    return undef;
}

true;
