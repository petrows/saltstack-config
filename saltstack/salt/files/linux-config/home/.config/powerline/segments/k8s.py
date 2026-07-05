"""Powerline segments showing the current kubernetes context.

Reads the kubeconfig (KUBECONFIG env or ~/.kube/config) and renders
the current context, its cluster and namespace. Used by the manually
activated `petro-k8s` shell theme, see `k8s-prompt` in fish config.
"""

import os

from powerline.theme import requires_segment_info

try:
    import yaml
except ImportError:
    yaml = None


def _kubeconfig_paths(environ):
    """Candidate kubeconfig files, honoring the KUBECONFIG variable."""
    env_value = environ.get("KUBECONFIG", "")
    if env_value:
        return [path for path in env_value.split(os.pathsep) if path]
    home = environ.get("HOME", os.path.expanduser("~"))
    return [os.path.join(home, ".kube", "config")]


def _current_context(environ):
    """Return dict with context/cluster/namespace or None."""
    if yaml is None:
        return None
    for path in _kubeconfig_paths(environ):
        try:
            with open(path, "r", encoding="utf-8") as handle:
                config = yaml.safe_load(handle) or {}
        except (OSError, yaml.YAMLError):
            continue
        current = config.get("current-context")
        if not current:
            continue
        context = {}
        for entry in config.get("contexts") or []:
            if entry.get("name") == current:
                context = entry.get("context") or {}
                break
        return {
            "context": current,
            "cluster": context.get("cluster", ""),
            "namespace": context.get("namespace", "default"),
        }
    return None


@requires_segment_info
def kubernetes(pl, segment_info, show_cluster=True, show_namespace=True):
    """Render current k8s context, cluster and namespace segments."""
    del pl  # unused, required by powerline calling convention
    current = _current_context(segment_info["environ"])
    if not current:
        return None
    segments = [
        {
            "contents": "⎈ " + current["context"],
            "highlight_groups": ["k8s_context", "information:priority"],
        }
    ]
    if show_cluster and current["cluster"] and current["cluster"] != current["context"]:
        segments.append({
            "contents": current["cluster"],
            "highlight_groups": ["k8s_cluster", "information:regular"],
        })
    if show_namespace:
        segments.append({
            "contents": current["namespace"],
            "highlight_groups": ["k8s_namespace", "information:regular"],
        })
    return segments
