FROM ubuntu:latest
ARG TARGETARCH

# Install git, vim, curl, unzip
RUN export CWD=$PWD && \
    cd "$(mktemp -d)" && \
    apt-get -y update && \
    apt-get install -y git vim curl unzip

# Install talosctl
RUN curl -sL https://talos.dev/install | sh

# Install kubectl
RUN curl -LO https://dl.k8s.io/release/v1.32.0/bin/linux/$TARGETARCH/kubectl && \
     install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
     rm -rf kubectl

# Install Tofu
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh && \
     chmod +x ./install-opentofu.sh && \
     ./install-opentofu.sh --install-method standalone --skip-verify && \
     rm -f install-opentofu.sh

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
     chmod +x get_helm.sh && \
     ./get_helm.sh && \
     rm -f get_helm.sh

# Install Kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
     mv kustomize /usr/local/bin/kustomize && \
     chmod +x /usr/local/bin/kustomize

# Install Helmfile
RUN curl -sSL -o helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v0.171.0/helmfile_0.171.0_linux_$TARGETARCH.tar.gz && \
     mkdir temp_helmfile && \
     tar -xvzf helmfile.tar.gz -C temp_helmfile && \
     rm -f helmfile.tar.gz && \
     chmod +x temp_helmfile/helmfile && \
     mv temp_helmfile/helmfile /usr/local/bin/helmfile && \
     rm -rf temp_helmfile

# Install ArgoCD CLI
RUN curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-$TARGETARCH && \
     chmod +x argocd && \
     mv argocd /usr/local/bin/argocd

# Install K9s
RUN curl -sSL -o k9s.tar.gz https://github.com/derailed/k9s/releases/download/v0.50.2/k9s_Linux_$TARGETARCH.tar.gz && \
     mkdir temp_k9s && \
     tar -xvzf k9s.tar.gz -C temp_k9s && \
     rm -f k9s.tar.gz && \
     chmod +x temp_k9s/k9s && \
     mv temp_k9s/k9s /usr/local/bin/k9s && \
     rm -rf temp_k9s

RUN rm -rf * && \
    cd $CWD
