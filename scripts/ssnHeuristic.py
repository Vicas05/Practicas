import os
import subprocess
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import networkx as nx

class SSNBuilder:
    def __init__(self, fasta_file, out_dir):
        self.fasta_file = fasta_file
        self.out_dir = out_dir
        self.df = None
        self.all_results = {}

    def calculate_distances(self):
        """
        Calculates Clustal-Omega distances for SSN creation
        """
        os.makedirs(self.out_dir, exist_ok=True)

        dist_file = os.path.join(self.out_dir, "dist.dist")
        clustering_file = os.path.join(self.out_dir, "clustering.clt")
        aln_file = os.path.join(self.out_dir, "alignment.aln")
        log_file = os.path.join(self.out_dir, "log.log")

        cmd = [
            "clustalo",
            "-i", self.fasta_file,
            "-t", "protein",
            "--full-iter",
            "--distmat-out", dist_file,
            "--clustering-out", clustering_file,
            "-o", aln_file,
            "--outfmt", "fa",
            "--output-order", "tree-order",
            "--iter", "2",
            "--threads", "18",
            "-l", log_file,
            "-v",
            "--force",
        ]

        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            raise RuntimeError(f"Clustal Omega failed:\n{result.stderr}")

        if not os.path.exists(dist_file):
            raise FileNotFoundError("Distance matrix file not generated.")

        df = pd.read_csv(
            dist_file,
            sep=r"\s+",
            header=None,
            skiprows=1,
        )
        
        df = df.set_index(0)
        df = df.astype(float)
        df.columns = df.index

        self.df = df
        return df

    def plot_distance_histogram(self):
        vals = self.df.values
        upper = vals[np.triu_indices_from(vals, k=1)]

        plt.figure()
        plt.hist(upper, bins=100)
        plt.xlabel("Pairwise Distance")
        plt.ylabel("Frequency")
        plt.title("Distance Distribution")
        plt.show()

    def analyze_seq(self, seq,
                    r1=9.6e-4,r2=3e-3,r3=2.4e-2,
                    num1=3,num=1,co_value=1,
                    get_all=0.1, omit_all=0.6):
        d = self.df.loc[seq].values.ravel()
        names = self.df.index.values

        dmin = d.min()
        dmax = d.max()
        L = dmax - dmin

        bins = np.linspace(dmin, dmax, 101)
        bin_index = (np.digitize(d, bins) - 1).astype(int).ravel()

        bin_seqs = {i: [] for i in range(100)}
        for name, dist, b in zip(names, d, bin_index):
            if 0 <= b < 100:
                bin_seqs[b].append(name)

        counts, edges = np.histogram(d, bins=bins)

        size = len(self.df)
        alpha = r1 * size
        beta  = r2 * size
        gamma = r3 * size

        co1 = co2 = co3 = co_value
        co1_found = co2_found = co3_found = False

        for c, e in zip(counts, edges):
            if e > get_all and e <= omit_all:
                if not co1_found and c > alpha:
                    co1 = e; co1_found = True
                if not co2_found and c > beta:
                    co2 = e; co2_found = True
                if not co3_found and c > gamma:
                    co3 = e; co3_found = True

        test = []
        for i, (c, e) in enumerate(zip(counts, edges[:-1])):
            seqs_in_bin = bin_seqs[i]

            if e < get_all and c > 0:
                test.append((float(e), int(c), seqs_in_bin))
            elif e >= omit_all:
                continue
            elif e <= co1:
                if c < num1 and c > 0:
                    test.append((float(e), int(c), seqs_in_bin))
            elif e <= co2 and c > 0:
                if c < num:
                    test.append((float(e), int(c), seqs_in_bin))
            elif e <= co3 and c > 0:
                if c < num:
                    test.append((float(e), int(c), seqs_in_bin))

        result = {
            "co1": float(co1),
            "co2": float(co2),
            "co3": float(co3),
            "bins": test
        }
        self.all_results[seq] = result
        return result

    def getGraph(self):
        edges_set = set()
        for seq, info in self.all_results.items():
            cluster_seqs = set()
            for _, _, bin_seqs in info['bins']:
                cluster_seqs.update(bin_seqs)
            cluster_seqs = sorted(cluster_seqs)

            for i, s1 in enumerate(cluster_seqs):
                for j, s2 in enumerate(cluster_seqs):
                    if i >= j:
                        continue
                    if s1 in self.df.index and s2 in self.df.columns:
                        pident = self.df.loc[s1, s2]
                    else:
                        pident = 0.0
                    edges_set.add((s1, s2, pident))

        G = nx.Graph()
        for s1, s2, _ in edges_set:
            G.add_edge(s1, s2)
        return G

    @staticmethod
    def score_ssn(G):
        N = G.number_of_nodes()
        E = G.number_of_edges()
        k = 2 * E / N
        lcc_frac = max(len(c) for c in nx.connected_components(G)) / N
        score = 0
        score -= abs(k - 10)
        score -= abs(lcc_frac - 0.5) * 10
        score -= len(list(nx.connected_components(G))) * 0.05
        return score

    def buildNetwork(self, out_folder):
        os.makedirs(out_folder, exist_ok=True)
        net_file = os.path.join(out_folder, "net_single.net")

        edges_set = set()
        node_metadata = {}

        for seq, info in self.all_results.items():
            cluster_seqs = set()
            for _, _, bin_seqs in info['bins']:
                cluster_seqs.update(bin_seqs)
            cluster_seqs = sorted(cluster_seqs)

            for i, s1 in enumerate(cluster_seqs):
                tag = s1.split('.')[-1]
                node_metadata[s1] = tag
                for j, s2 in enumerate(cluster_seqs):
                    if i >= j:
                        continue
                    if s1 in self.df.index and s2 in self.df.columns:
                        pident = self.df.loc[s1, s2]
                    else:
                        pident = 0.0
                    edges_set.add((s1, s2, pident))

        G = nx.Graph()
        for s1, s2, _ in edges_set:
            G.add_edge(s1, s2)
        degrees = dict(G.degree())

        with open(net_file, 'w') as f:
            f.write("qseqid,sseqid,distance,degree_qseqid,degree_sseqid\n")
            for s1, s2, pident in sorted(edges_set):
                deg1 = degrees.get(s1, 0)
                deg2 = degrees.get(s2, 0)
                f.write(f"{s1},{s2},{pident},{deg1},{deg2}\n")


        print(f"Net file written: {net_file}")
        print(f"Edges: {len(edges_set)}, Nodes: {len(node_metadata)}")