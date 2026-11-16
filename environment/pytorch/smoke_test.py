"""Minimal real CUDA forward/backward/update check; no Uni-AdaFocus import."""
import torch


def main():
    print(f"torch={torch.__version__} torch_cuda={torch.version.cuda}")
    if not torch.cuda.is_available():
        raise RuntimeError("CUDA unavailable; GPU smoke test did not run")
    device = torch.device("cuda:0")
    print(f"gpu={torch.cuda.get_device_name(device)}")
    model = torch.nn.Linear(4, 2).to(device)
    opt = torch.optim.SGD(model.parameters(), lr=0.1)
    x = torch.ones((3, 4), device=device)
    target = torch.zeros((3, 2), device=device)
    before = model.weight.detach().clone()
    opt.zero_grad()
    prediction = model(x)
    loss = torch.nn.functional.mse_loss(prediction, target)
    loss.backward()
    if model.weight.grad is None:
        raise RuntimeError("missing weight gradient")
    opt.step()
    torch.cuda.synchronize(device)
    if not torch.isfinite(loss).item() or torch.equal(before, model.weight.detach()):
        raise RuntimeError("nonfinite loss or no parameter update")
    print(f"PASS cuda_forward_backward_update loss={loss.item():.6f}")


if __name__ == "__main__":
    main()
