TEST_ROOT=$PWD
flakeA=$TEST_ROOT/flakeA
flakeB=$TEST_ROOT/flakeB

for repo in $flakeA $flakeB; do
    rm -rf $repo $repo.tmp
    mkdir $repo
    git -C $repo init
    git -C $repo config user.email "foobar@example.com"
    git -C $repo config user.name "Foobar"
done

# Test circular flake dependencies.
cat > $flakeA/flake.nix <<EOF
{
  inputs.b.url = git+file://$flakeB;
  inputs.b.inputs.a.follows = "/";

  outputs = { self, nixpkgs, b }: {
    foo = 123 + b.bar;
    xyzzy = 1000;
  };
}
EOF

git -C $flakeA add flake.nix

cat > $flakeB/flake.nix <<EOF
{
  inputs.a.url = git+file://$flakeA;

  outputs = { self, nixpkgs, a }: {
    bar = 456 + a.xyzzy;
  };
}
EOF

git -C $flakeB add flake.nix
git -C $flakeB commit -a -m 'Foo'

NIX="/home/matthew/src/nix/inst/bin/nix"

$NIX flake --experimental-features "flakes nix-command" list-inputs $flakeA
$NIX flake --experimental-features "flakes nix-command" list-inputs $flakeA --json