package mover::View::HTML;
use Moose;
use namespace::autoclean;
extends 'Catalyst::View::TT';
with 'Catalyst::View::Component::jQuery';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
    render_die         => 1,
    CATALYST_VAR       => 'c',
#------ See mover.pm for INCLUDE_PATH INFO
#    INCLUDE_PATH       => [ 
#        mover->path_to('root', 'src'),
#        mover->path_to('root', 'forms','miniforms'),
#        mover->path_to( 'forms','miniforms'),
#         ],

    # Set to 1 for detailed timer stats in your HTML as comments
    TIMER    => 0,
    ENCODING => 'utf-8',
         # This is your wrapper template located in the 'root/src'
    WRAPPER     => 'wrapper.tt2',
#    PRE_PROCESS => 'config/main',
);

=head1 NAME

mover::View::HTML - TT View for mover

=head1 DESCRIPTION

TT View for mover.

=head1 SEE ALSO

L<mover>

=head1 AUTHOR

austin,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
1;
