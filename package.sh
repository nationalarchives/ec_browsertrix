#!/bin/bash -C
#Running with noclobber so that redirection does not overwrite existing files

tmpdir=`mktemp -d` || exit 1

function cleanup {
  rm -rf "$tmpdir" 
}

trap cleanup EXIT

targdir="${tmpdir}/${1}"
packagelog="${targdir}/logs/package.log"
mkdir "$targdir"
echo "Working in tmpdir $targdir"

test -e "configs/${1}.yaml" || { cat >&2 <<EOF
Bad target. Legal invocations:
`cd configs; for x in *.yaml; do echo $0 ${x%.yaml}; done`
EOF
exit 1
}

cp -vl crawls/collections/"$1"/"${1}".wacz crawls/collections/"$1"/pages/pages.jsonl "$targdir" &&
cp -vlr logs/"$1" "$targdir"/logs &&
cat configs/"$1".yaml > "${targdir}/logs/${1}.yaml" &&
echo "Writing $packagelog" &&
{
cat >"$packagelog" <<EOF
Command: $0 $@
Git remote:
`git remote -v`

Git revision: `git rev-parse HEAD`
Git status:
`git stat`
EOF
} &&
echo "Delivery prepared" || {
cat >&2 <<EOF
Unable to prepare delivery directory "$targdir"
You may need to run 'sudo chown -R "$USER" crawls/'
EOF
exit 1
}

(cd "$tmpdir" && tar cJ -f "${OLDPWD}/$1".tar.xz "$1") &
tarpid=$!
echo "Tarring... [pid $tarpid]"

(cd "$tmpdir" && zip -q -r "${OLDPWD}/$1".zip "$1") &
zippid=$!
echo "Zipping... [pid $zippid]"

exitcode=0
wait $tarpid
if [ $? -eq 0 ]; then
  echo "Tar succeeded"
else
  echo "Tar failed" >&2
  exitcode=1
fi

wait $zippid
if [ $? -eq 0 ]; then
  echo "Zip succeeded"
else
  echo "Zip failed" >&2
  exitcode=1
fi

[ $exitcode -ne 0 ] && exit 1

echo "All done."
