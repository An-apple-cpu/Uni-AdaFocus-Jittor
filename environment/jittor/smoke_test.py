"""Minimal real Jittor CUDA forward/backward/update check."""
import jittor as jt
from jittor import nn


def main():
    print(f"jittor={jt.__version__} has_cuda={jt.has_cuda}")
    if not jt.has_cuda:
        raise RuntimeError("Jittor CUDA unavailable; GPU smoke test did not run")
    jt.flags.use_cuda = 1
    layer = nn.Linear(4, 2)
    optimizer = jt.optim.SGD(layer.parameters(), lr=0.1)
    x = jt.ones((3, 4))
    target = jt.zeros((3, 2))
    before = layer.weight.numpy().copy()
    prediction = layer(x)
    loss = ((prediction - target) ** 2).mean()
    optimizer.step(loss)
    jt.sync_all(True)
    after = layer.weight.numpy()
    if not ((before != after).any()):
        raise RuntimeError("no parameter update")
    print(f"PASS jittor_cuda_forward_backward_update loss={float(loss.item()):.6f}")


if __name__ == "__main__":
    main()
