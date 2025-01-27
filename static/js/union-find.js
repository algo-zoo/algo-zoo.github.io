export class UnionFind {
  constructor(N) {
    this.N = N;
    this.parents = Array.from({ length: N }, () => null);
    this.group_sizes = Array.from({ length: N }, () => 1);
  }

  root(i) {
    const v = this.parents[i];
    if (v == null)
      return i;
    this.parents[i] = this.root(v);
    return this.parents[i];
  }

  is_same(i, j) {
    return this.root(i) == this.root(j);
  }

  unite(i, j) {
    const u = this.root(i); 
    const v = this.root(j);
    if (u == v)
      return;
    if (this.group_sizes[u] < this.group_sizes[v]) {
      this.unite(v, u);
    } else {
      this.parents[v] = u;
      this.group_sizes[u] += this.group_sizes[v];
      this.group_sizes[v] = 0;
    }
  }

  size(i) {
    return this.group_sizes[this.root(i)];
  }
}
