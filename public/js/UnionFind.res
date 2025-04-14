module UnionFind = {
  type t = {
    n: int,
    parents: array<option<int>>,
    groupSizes: array<int>
  }

  let create = (n: int): t => {
    {
      n: n,
      parents: Array.make(n, None),
      groupSizes: Array.make(n, 1)
    }
  }

  let rec root = (uf: t, i: int): int =>
    switch uf.parents[i] {
    | None => i
    | Some(p) => {
        let r = root(uf, p);
        uf.parents[i] = Some(r);
        r
      }
    }

  let isSame = (uf: t, i: int, j: int): bool =>
    root(uf, i) == root(uf, j)

  let rec unite = (uf: t, i: int, j: int): unit => {
    let u = root(uf, i)
    let v = root(uf, j)
    if (u != v) {
      if (uf.groupSizes[u] < uf.groupSizes[v]) {
        unite(uf, v, u)
      } else {
        uf.parents[v] = Some(u)
        uf.groupSizes[u] = uf.groupSizes[u] + uf.groupSizes[v]
        uf.groupSizes[v] = 0
      }
    }
  }

  let size = (uf: t, i: int): int =>
    uf.groupSizes[root(uf, i)]
}
