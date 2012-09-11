use strict;
use warnings;

use mover;

my $app = mover->apply_default_middlewares(mover->psgi_app);
$app;

