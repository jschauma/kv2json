#! /bin/sh

TDIR="$(mktemp -d)"

trap "rm -fr ${TDIR}" 0

for f in input*; do
	num=${f##*-}
	invocation=$(sed -e 's/^# *//;q' "${f}")

	perl -T ../src/kv2json.pl ${invocation} <${f} >"${TDIR}/out"
	if ! diff -bu "output-${num}" "${TDIR}/out"; then
		echo "=> $num failed"
	fi
done
