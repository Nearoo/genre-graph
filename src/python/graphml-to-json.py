import networkx as nx
import json
from networkx.readwrite import json_graph


def setup_edge(e):
  f, t, data = e
  data['weight'] = float.fromhex(data['weight'])
  return f, t, data

G = nx.read_graphml('src/data/genre_graph.graphml')

G.update(
  edges = [setup_edge(e) for e in list(G.edges.data())]
)

G_tree = nx.maximum_spanning_tree(G.to_undirected())



print(len(G_tree.edges))

with open('public/json/genre_graph.json', 'w') as f:
  json.dump(json_graph.node_link_data(G_tree), f, indent=4)
