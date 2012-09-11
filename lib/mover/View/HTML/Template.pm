package mover::View::HTML::Template;

use strict;
use base 'Catalyst::View::HTML::Template';
#
__PACKAGE__->config(
        die_on_bad_params => 0,
        file_cache        => 0,
        file_cache_dir    => '/tmp/cache',
        path => [ mover->path_to( ('root'),('src')), ],
#        utf8     => 1,
        debug       => 1,
#        stack_debug => 1,
        cache   => 1,
#        shared_cache_debug  => 1,
#        memory_debug        => 1,   #needs GTop
#        force_untaint       => 1,  #perl has to be in taint mode
#        associate => $query,
        case_sensitive => 0, 
     );
    
   





=head1 NAME

mover::View::HTML::Template - HTML::Template View Component

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice component.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
