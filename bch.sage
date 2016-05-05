import random

CHARACTERISTIC=2
FIELDDEGREE=5
Q=CHARACTERISTIC**FIELDDEGREE
M=2
N=93
DISTANCE=5
DEGREE=6
COUNT=256


assert(((Q**M)-1) % N == 0)

print "BASEORDER:", Q
print "EXTORDER:", Q**M

def randlist(n, all):
    ret = []
    for i in range(n):
        ret.append(random.choice(all))
    return ret

def polyfromarray(var, arr):
    ret = 0
    for a in arr:
        ret = ret * var + a
    return ret

found = 0
while found < COUNT:
    print "* ITERATION"
    F.<f> = GF(Q, repr='int', modulus='random')
    print "  * FIELD mod", F.modulus()

    F_all = [x for x in F]
    FP.<fp> = F[]
    F_from_int = {f.integer_representation() : f for f in F}

    if M == 1:
        E.<e> = F.extension(fp+1)
    else:
        while True:
            pol = polyfromarray(fp, [1] + randlist(M, F_all))
            if pol.is_primitive():
                break
        E.<e> = F.extension(pol)
    print "  * EXTFIELD mod", E.modulus()

    ok = False
    while not ok:
        alpha = polyfromarray(e, randlist(M, F_all)) ** ((Q**M-1) // N)
        if alpha^N != 1:
            continue
        for di in N.divisors():
            if di == N:
                ok = True
                break
            elif alpha^di == 1:
                break

    print "  * ALPHA", alpha

    mp=[]
    ld={}
    print "  * LCM"
    num = DISTANCE-1 
    find = 0
    for i in range(1,N-num):
        mp.append((alpha^i).minpoly())
        if (i >= num):
            generator=lcm(mp[-num:])
            if (generator.degree() == DEGREE):
                table=[]
                for j in range(Q):
                    n = 0
                    for p in range(generator.degree()):
                        n = n * Q + (F_from_int[j] * generator.list()[generator.degree()-1-p]).integer_representation()
                    table.append(n)
                print "      * TABLE: {%s}, // N=%i M=%i F=(%r) E=(%r) alpha=(%r) powers=%i..%i minpolys=%s gen=(%s)" % (' '.join(["0x%08x" % v for v in table]), N, M, F.modulus(), E.modulus(), alpha, i-num+1, i, mp[-num:], generator)
                find = 1
    found += find

